import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tfnd_app/models/AddBusinessModel.dart';
import 'package:tfnd_app/screens/businessSide/addCollections.dart';
import 'package:tfnd_app/screens/businessSide/edit_business.dart';
import 'package:tfnd_app/screens/userSide/scanner.dart';
import 'package:tfnd_app/themes/color.dart';
import 'package:tfnd_app/widgets/reusable_outlined_button.dart';
import 'package:tfnd_app/widgets/reusable_text.dart';

class businessDets extends StatefulWidget {
  final AddBusinessModel business;
  final String emaildetails;
  final String cureeemails;
  businessDets({
    Key? key,
    required this.business,
    required this.emaildetails,
    required this.cureeemails,
  }) : super(key: key);

  @override
  State<businessDets> createState() => _businessDetailsState();
}

class _businessDetailsState extends State<businessDets> {
  File? collectionPhoto;

  // Create a stream controller
  late StreamController<QuerySnapshot> _streamController;

  @override
  void initState() {
    super.initState();

    print("this is my current Id..${widget.business.uid.toString()}");

    // Initialize the stream controller
    _streamController = StreamController<QuerySnapshot>();

    // Set up the stream subscription
    FirebaseFirestore.instance
        .collection('BusinessCollections')
        .doc(widget.business.uid.toString())
        .collection('subcollections')
        .snapshots()
        .listen((data) {
      _streamController.add(data);
    });
  }

  bool isLoading = false;
  // Dispose of the stream controller when the widget is disposed
  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: AppColor.hintColor, // Change this color to the desired one
        ),
        centerTitle: true,
        title: ReusableText(
          title: widget.business.name,
          color: AppColor.blackColor,
          size: 20,
          weight: FontWeight.w500,
        ),
        actions: [],
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
                        SizedBox(
                          height: 10,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.btnColor,
                            textStyle: const TextStyle(fontSize: 18),
                            minimumSize: const Size.fromHeight(40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: isLoading
                              ? null
                              : () async {
                                  setState(() {
                                    isLoading = true;
                                  });

                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          Scanner(widget.emaildetails),
                                    ),
                                  );
                                  setState(() {
                                    isLoading = false;
                                  });

                                  // Close the dialog
                                },
                          child: isLoading
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 35,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 3,
                                        color: AppColor.blackColor,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Text(
                                      "Please Wait",
                                      style: TextStyle(
                                        color: AppColor.blackColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                )
                              : const Text(
                                  "Proceed to discounts",
                                  style: TextStyle(
                                    color: AppColor.blackColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    const Divider(),
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
                    return const Text("");
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
                        return GestureDetector(
                          onTap: () {
                            _showCollectionPopup(
                                data['name'], data['image_url']);
                          },
                          child: Column(
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

  void _showCollectionPopup(String collectionName, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              imageUrl.isNotEmpty
                  ? Container(
                      width: 400, // Adjust the width as needed
                      height: 400, // Adjust the height as needed
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Text(
                      'Image not available',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
              const SizedBox(
                height: 10,
              ),
              Center(child: Text(collectionName)),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Close',
                style: TextStyle(
                    color: AppColor.btnColor, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}
