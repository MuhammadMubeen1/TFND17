import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tfnd_app/themes/color.dart';
import 'package:tfnd_app/widgets/reusable_text.dart';

class AddCollections extends StatefulWidget {
  String idd;
  AddCollections({Key? key, required this.idd});

  @override
  State<AddCollections> createState() => _AddCollectionsState();
}

class _AddCollectionsState extends State<AddCollections> {
  TextEditingController nameController = TextEditingController();

  File? collectionPhoto;

  String? nameErrorText;
  bool isLoading = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void initState() {
    super.initState();
    print("this is my current Id..${widget.idd.toString()}");
  }

  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await ImagePicker().getImage(source: source);

    if (pickedFile != null) {
      setState(() {
        collectionPhoto = File(pickedFile.path);
      });
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

      await FirebaseFirestore.instance
          .collection('BusinessCollections')
          .doc(widget.idd)
          .collection('subcollections')
          .add({
        'name': nameController.text,
        'image_url': downloadUrl,
      });

      Fluttertoast.showToast(
          msg: "Collection data uploaded successful",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
          backgroundColor: AppColor.btnColor,
          textColor:AppColor.blackColor,
          fontSize: 16.0);
      Navigator.pop(context);

      setState(() {
        isLoading = false;
        collectionPhoto = null;
        nameController.clear();
        nameErrorText = null;
      });
    } else {
      Fluttertoast.showToast(
          msg: "Please fill in all required fields",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
          backgroundColor: AppColor.btnColor,
          textColor: Colors.black,
          fontSize: 16.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: AppColor.hintColor,
        ),
        centerTitle: true,
        title: const ReusableText(
          title: "Add Collection",
          color: AppColor.blackColor,
          size: 20,
          weight: FontWeight.w500,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  const ReusableText(
                    title: "Collection ",
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
                    child: Container(
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
                          : const Center(
                              child: ReusableText(
                                title: "Add Collection Images",
                                color: AppColor.blackColor,
                                size: 13,
                              ),
                            ),
                    ),
                  ),

                  // Show message if collectionPhoto is null
                  if (collectionPhoto == null)
                    const Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Please upload an image",
                        style: TextStyle(color: Colors.red),
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
                        color: AppColor.blackColor,
                        size: 12,
                        weight: FontWeight.bold,
                      ),
                      const SizedBox(
                        height: 10,
                      ),

                      TextFormField(
                        maxLength: 25,
                        controller: nameController,
                        decoration: InputDecoration(
                          hintText: 'Type Here',
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors
                                    .grey), // Set the border color to pink
                            borderRadius: BorderRadius.circular(18.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors
                                    .grey), // Set the border color to pink
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
                  const SizedBox(
                    height: 25,
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
                              "Publish",
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
