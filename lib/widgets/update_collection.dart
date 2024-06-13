import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tfnd_app/themes/color.dart';
import 'package:tfnd_app/widgets/reusable_text.dart';

class Updatecollection extends StatefulWidget {
  final String iddd, idbus;

  Updatecollection({Key? key, required this.iddd , required this.idbus});

  @override
  State<Updatecollection> createState() => _UpdatecollectionState();
}

class _UpdatecollectionState extends State<Updatecollection> {
  TextEditingController nameController = TextEditingController();

  File? collectionPhoto;
  String _updatedName = '';
  String _updatedImageUrl = '';
  String? nameErrorText;
  bool isLoading = false;
 bool _isLoadingData = true; 
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void initState() {
     _fetchUpdatedData();
    print("Collection id, ${widget.iddd}");
      print("business id, ${widget.idbus}");
    super.initState();
    print("this is my current Id..${widget.iddd.toString()}");
  }

  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await ImagePicker().getImage(source: source);

    if (pickedFile != null) {
      setState(() {
        collectionPhoto = File(pickedFile.path);
      });
    }
  }
Future<void> _fetchUpdatedData() async {
    try {
      setState(() {
        _isLoadingData = true; // Set loading state to true when fetching data
      });

      // Fetch the updated document to get its data
      DocumentSnapshot updatedDocSnapshot = await FirebaseFirestore.instance
          .collection('BusinessCollections')
          .doc(widget.idbus)
          .collection('subcollections')
          .doc(widget.iddd)
          .get();

      // Get the data from the updated document
      Map<String, dynamic> updatedData =
          updatedDocSnapshot.data() as Map<String, dynamic>;

      // Update state variables with the updated data
      setState(() {
        _updatedName = updatedData['name'];
        _updatedImageUrl = updatedData['image_url'];
        _isLoadingData = false; // Set loading state to false after data is fetched
      });

      print("Hello everyone $_updatedName");
    } catch (error) {
      // Error handling...
    }
  }

 Future<void> _saveCollectionData() async {
  if (_formKey.currentState!.validate() && collectionPhoto != null) {
    String imageName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('collection_images/$imageName.jpg');

    setState(() {
      isLoading = true;
    });

    UploadTask uploadTask = storageReference.putFile(collectionPhoto!);
    TaskSnapshot storageTaskSnapshot = await uploadTask.whenComplete(() {});

    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();

    try {
      await FirebaseFirestore.instance
          .collection('BusinessCollections')
          .doc(widget.idbus)
          .collection('subcollections')
          .doc(widget.iddd) // Use the same document ID for updating
          .set({
        'name': nameController.text,
        'image_url': downloadUrl,
      }, SetOptions(merge: true)); // Use merge option to update only provided field

      Fluttertoast.showToast(
          msg: "Collection data updated successful",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 2,
          backgroundColor: AppColor.btnColor,
          textColor: Colors.black,
          fontSize: 16.0);
      Navigator.pop(context);

      setState(() {
        isLoading = false;
        collectionPhoto = null;
        nameController.clear();
        nameErrorText = null;
      });
    } catch (error) {
      print("Error updating collection: $error");
      Fluttertoast.showToast(
          msg: "Failed to update collection data",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
          backgroundColor: AppColor.btnColor,
          textColor: Colors.black,
          fontSize: 16.0);
    }
  } else {
    Fluttertoast.showToast(
        msg: "Please fill in all required fields",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        backgroundColor: AppColor.blackColor,
        textColor: AppColor.btnColor,
        fontSize: 16.0);
  }
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
        title: const ReusableText(
          title: "Update Collection",
          color: AppColor.blackColor,
          size: 20,
          weight: FontWeight.w500,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _isLoadingData // Show a loading indicator if data is being fetched
              ? Center(child: CircularProgressIndicator())
              :  SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  const ReusableText(
                    title: "Collection",
                    color: AppColor.blackColor,
                    size: 17,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                    GestureDetector(
                      onTap: () {
                        _showImagePicker(context);
                      },
                    child: Stack(
                      children: [
                    
                     Container(
                       height: 200,
                       width: double.infinity,
                       decoration: BoxDecoration(
                         border: Border.all(color: AppColor.primaryColor),
                         borderRadius: BorderRadius.circular(10),
                       ),
                       child: collectionPhoto != null
                           ? Image.file(
                               collectionPhoto!,
                               fit: BoxFit.cover,
                             )
                           :  _updatedImageUrl!= null
                             ? Image.network(
                                 _updatedImageUrl!,
                                 fit: BoxFit.cover,
                               )
                             : const Center(
                                 child: ReusableText(
                                   title: "Add Collection Images",
                                   color: AppColor.blackColor,
                                   size: 13,
                                 ),
                               
                                         
                             ),
                     ),
                    
                                      const  Positioned(
                          bottom: 8,
                          right: 8,
                          child: Icon(
                            Icons.add_a_photo,
                            color: AppColor.btnColor, // Customize the color as needed
                            size: 30, // Customize the size as needed
                          ),
                        ),
                             
                      ],
                                    
                    ),
                  ),
                  // Show message if collectionPhoto is null
                  if (collectionPhoto == null)
                    const Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Please upload an image",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  const SizedBox(
                    height: 25,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ReusableText(
                        title: "Collection Name",
                        color: AppColor.textColor,
                        size: 12,
                        weight: FontWeight.bold,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        maxLength: 30,
                        controller: nameController,
                        decoration: InputDecoration(
                          hintText: _updatedName,
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.grey,
                            ),
                            borderRadius: BorderRadius.circular(18.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.grey,
                            ),
                            borderRadius: BorderRadius.circular(18.0),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Container(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.btnColor,
                        textStyle: const TextStyle(fontSize: 18),
                        minimumSize: const Size.fromHeight(50),
                      ),
                      onPressed: () async {
                        _saveCollectionData();
                      },
                      child: isLoading
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  color: Colors.black,
                                ),
                                SizedBox(
                                  width: 24,
                                ),
                                Text(
                                  "Please Wait...",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                          : const Text(
                              "Update",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showImagePicker(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 120.0,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(
                  Icons.photo,
                  color: AppColor.pinktextColor,
                ),
                title: const Text(
                  'Gallery',
                ),
                onTap: () {
                  _getImage(ImageSource.gallery);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.camera,
                  color: AppColor.pinktextColor,
                ),
                title: const Text('Camera'),
                onTap: () {
                  _getImage(ImageSource.camera);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
