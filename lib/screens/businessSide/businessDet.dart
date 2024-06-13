import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tfnd_app/models/AddBusinessModel.dart';
import 'package:tfnd_app/screens/businessSide/addCollections.dart';
import 'package:tfnd_app/screens/businessSide/edit_business.dart';
import 'package:tfnd_app/themes/color.dart';
import 'package:tfnd_app/widgets/reusable_outlined_button.dart';
import 'package:tfnd_app/widgets/reusable_text.dart';
import 'package:tfnd_app/widgets/update_collection.dart';

class BusinessDet extends StatefulWidget {
  final AddBusinessModel business;
  final String emaildetails;
  const BusinessDet({
    Key? key,
    required this.business,
    required this.emaildetails,
  }) : super(key: key);

  @override
  State<BusinessDet> createState() => _BusinessDetailsScreenState();
}

class _BusinessDetailsScreenState extends State<BusinessDet> {
  late StreamController<QuerySnapshot> _streamController;

  @override
  void initState() {
    super.initState();
    _streamController = StreamController<QuerySnapshot>();

    FirebaseFirestore.instance
        .collection('BusinessCollections')
        .doc(widget.business.uid.toString())
        .collection('subcollections')
        .snapshots()
        .listen((data) {
      _streamController.add(data);
    });
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.bgColor,
        iconTheme: const IconThemeData(
          color: AppColor.hintColor,
        ),
        centerTitle: true,
        title: ReusableText(
          title: widget.business.name,
          color: AppColor.blackColor,
          size: 20,
          weight: FontWeight.w500,
        ),
        actions: [
          IconButton(
            icon: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditBusiness(
                      uid: widget.business.uid.toString(),
                      image: widget.business.image.toString(),
                      useremail: widget.emaildetails,
                      bussinessname: widget.business.name.toString(),
                      category: widget.business.category.toString(),
                      description: widget.business.description.toString(),
                      discount: widget.business.discount.toString(),
                      discountenddate: widget.business.date.toString(),
                    ),
                  ),
                );
              },
              child: const ImageIcon(AssetImage("assets/icons/edit.png")),
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 175,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(widget.business.image.toString()),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 5),
                    Container(
                      width: 380,
                      child: ReusableText(
                        title: widget.business.description,
                        size: 13,
                        color: AppColor.textColor,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Divider(),
                    const SizedBox(height: 5),
                    Column(
                      children: [
                        ReusableText(
                          title:
                              "Up to ${widget.business.discount ?? 'null'}% OFF",
                          color: AppColor.blackColor,
                          weight: FontWeight.bold,
                        ),
                        const SizedBox(height: 5),
                        ReusableText(
                          title: "Offer ends ${widget.business.date}",
                          color: AppColor.textColor,
                          weight: FontWeight.bold,
                          size: 11,
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    const Divider(),
                    const SizedBox(height: 10),
                   
                    QrImageView(
                      data: " ${ widget.business.discount}| ${widget.business.name} | Congratulations! \n You have availed a ${widget.business.discount}% discount | ${widget.business.uid}",
                      version: QrVersions.auto,
                      size: 230,
                      
                      gapless: false,
                      errorStateBuilder: (context, error) {
                        return Container(
                          child: const Center(
                            child: Text(
                              'Uh oh! Something went wrong...',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Center(
                      child: ReusableOutlinedButton(
                        title: "Add Collection",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (BuildContext context) => AddCollections(
                                idd: widget.business.uid.toString(),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: _streamController.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                    return const Text("No data available");
                  }

                  return Padding(
                    padding: const EdgeInsets.all(10),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisExtent: 230,
                      ),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (BuildContext context, int index) {
                        var data = snapshot.data!.docs[index];
                        return Stack(
                          children: [
                            Column(
                              children: [
                                Container(
                                  height: 160,
                                  width: 160,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    image: DecorationImage(
                                      image: NetworkImage(data['image_url']),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Center(
                                  child: Container(
                                    width: 100,
                                    child: ReusableText(
                                      title: data['name'],
                                      color: AppColor.darkTextColor,
                                      size: 12,
                                      textAlign: TextAlign.center,
                                      weight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Positioned(
                              top: 2,
                              left: 5,
                              child: GestureDetector(
                                onTap: () {
                                  _showDeleteConfirmationDialog(
                                      data.id, widget.business.uid.toString());
                                },
                                child: const Icon(
                                  Icons.delete,
                                  color: AppColor.btnColor,
                                  size: 25,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 2,
                              right: 5,
                              child: GestureDetector(
                                onTap: () {

                                   Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (BuildContext context) => Updatecollection(
                                iddd: data.id, idbus: widget.business.uid.toString(),
                                
                              ),));
                               },
                                child: const Icon(
                                  Icons.edit,
                                  color: AppColor.btnColor,
                                  size: 25,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(
      String docId, String businessId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Confirmation'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this Collection?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel',  style: TextStyle(color: AppColor.blackColor, fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Delete',
                style: TextStyle(color: AppColor.btnColor, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                // Delete the item from Firebase
                FirebaseFirestore.instance
                    .collection('BusinessCollections')
                    .doc(businessId)
                    .collection('subcollections')
                    .doc(docId)
                    .delete()
                    .then((_) {
                  print("Item deleted successfully");
                }).catchError((error) {
                  print("Error deleting item: $error");
                });

                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }
}
