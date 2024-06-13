import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as Path;
import 'package:tfnd_app/models/AddBusinessModel.dart';
import 'package:tfnd_app/models/BusinessCategory.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tfnd_app/widgets/const.dart';
import 'package:tfnd_app/screens/businessSide/addCollections.dart';
import 'package:tfnd_app/themes/color.dart';
import 'package:tfnd_app/widgets/reusable_button.dart';
import 'package:tfnd_app/widgets/reusable_outlined_button.dart';
import 'package:tfnd_app/widgets/reusable_text.dart';
import 'package:tfnd_app/widgets/reusable_textformfield.dart';
import 'dart:io' as Io;

class EditBusiness extends StatefulWidget {
  String useremail,
      bussinessname,
      category,
      description,
      discount,
      discountenddate,
      uid,
      image;

  EditBusiness(
      {super.key,
      required this.useremail,
      required this.uid,
      required this.image,
      required this.bussinessname,
      required this.category,
      required this.description,
      required this.discount,
      required this.discountenddate});

  @override
  State<EditBusiness> createState() => _addBusinessState();
}

class _addBusinessState extends State<EditBusiness> {
  PickedFile? imageFile;

  UploadTask? task;
  String? firebasePictureUrl;
  bool isLoadFile = false;
  int? id;
    void dispose() {
    nameController.dispose();
    categoryController.dispose();
    descriptionController.dispose();
    dateController.dispose();
    discountController.dispose();
    super.dispose();
  }
  List<BusinessList> categories = [];

  TextEditingController nameController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController discountController = TextEditingController();
  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return "Name should not be empty";
    }
    return null;
  }

  String? validateCategory(String? value) {
    if (value == null || value.isEmpty) {
      return "Category should not be empty";
    }
    return null;
  }

  String? validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return "Description should not be empty";
    }
    return null;
  }

  String? validateDiscount(String? value) {
    if (value == null || value.isEmpty) {
      return "Discount should not be empty";
    }
    return null;
  }

  String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return "Date should not be empty";
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    getCategories();
    print(' user is ${widget.useremail} ');
    print('edit id   ${widget.uid.toString()}');

    nameController.text = widget.bussinessname.toString();
    categoryController.text = widget.category.toString();
    descriptionController.text = widget.description.toString();
    dateController.text = widget.discountenddate.toString();
    discountController.text = widget.discount.toString();
  }

  Future<void> updateBusiness() async {
    isLoading = true;
    setState(() {});

    try {
      // Extract updated data from form fields
      String newName = nameController.text.trim();
      String newCategory = categoryController.text.trim();
      String newDescription = descriptionController.text.trim();
      String newDiscount = discountController.text.trim();
      String newDiscountEndDate = dateController.text.trim();

      // Check if a new image has been selected
      String? updatedImage;
      if (imageFile != null) {
        await uploadFile(); // Upload the new image
        updatedImage = firebasePictureUrl; // Get the updated image URL
      } else {
        updatedImage = widget.image; // Keep the existing image URL
      }

      // Update the business details in Firestore
      await FirebaseFirestore.instance
          .collection('BusinessRegister')
          .doc(widget.useremail)
          .collection('Businesses')
          .doc(widget.uid)
          .update({
        'name': newName,
        'category': newCategory,
        'description': newDescription,
        'discount': newDiscount,
        'date': newDiscountEndDate,
        'image': updatedImage, // Update the image URL
        // Add other fields as needed
      });

      await FirebaseFirestore.instance
          .collection('BusinessRegister')
          .doc(widget.uid)
          .update({
        'name': newName,
        'category': newCategory,
        'description': newDescription,
        'discount': newDiscount,
        'date': newDiscountEndDate,
        'image': updatedImage, // Update the image URL
        // Add other fields as needed
      });

      isLoading = false;
      setState(() {});
      // Show a success message
      Fluttertoast.showToast(msg: 'Business details updated successfully',
      backgroundColor: AppColor.btnColor,
      textColor: Colors.black,
      
      );
      Navigator.pop(context, true);

      // Hide the loading bar after update is complete

      // Navigate to another screen or perform any other action as needed
      // Example: Navigator.pop(context);
    } catch (e) {
      isLoading = false;
      setState(() {});
      // Handle any errors
      print('Error updating business: $e');
      // Show an error message
      Fluttertoast.showToast(
        backgroundColor: AppColor.btnColor,
          msg: 'Failed to update business. Please try again.',  textColor: AppColor.blackColor, );

      // Hide the loading bar after update is complete
      setState(() {
        isLoadFile = false;
      });
    }
  }

  // Show a success message

  int numberOfCollections = 3;

  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  // bool isPass = true;

  getCategories() {
    try {
      categories.clear();
      setState(() {});
      FirebaseFirestore.instance
          .collection("BusinessCategory")
          .snapshots()
          .listen((event) {
        categories.clear();
        setState(() {});
        for (int i = 0; i < event.docs.length; i++) {
          BusinessList dataModel = BusinessList.fromJson(event.docs[i].data());
          categories.add(dataModel);

          print("my  catagories == ${categories.length}");
        }
        setState(() {});
      });
      setState(() {});
    } catch (e) {}
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
          title: "Edit Business",
          color: AppColor.blackColor,
          size: 20,
          weight: FontWeight.w500,
        ),
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 10,
                ),
                Center(
                  child: imageFile == null
                      ? GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: ((builder) => openGallery()),
                            );
                          },
                          child: Container(
                            height: 55,
                            width: 200,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                border:
                                    Border.all(color: AppColor.primaryColor)),
                            child: const Center(
                              child: ReusableText(
                                title: "Add Business Image",
                                color: AppColor.blackColor,
                                size: 13,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          height: 175,
                          width: double.infinity,
                          child: Image.file(
                            File(imageFile!.path),
                            fit: BoxFit.cover,
                          )),
                ),
                const SizedBox(
                  height: 25,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ReusableText(
                      title: "Business Name",
                      color: AppColor.textColor,
                      size: 12,
                      weight: FontWeight.bold,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    // ReusableTextForm(

                    //   validator: validateName,
                    //   controller: nameController,
                    //   hintText: "Type Here",
                    // )

                    TextFormField(
                      maxLength: 25,
                      decoration: InputDecoration(
                        hintText: "",
                        border: InputBorder.none,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          borderSide: BorderSide(
                              color: Colors.grey.shade300), // Border color
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide(
                              color: Colors.grey.shade300), // Border color
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide(
                              color: Colors.grey.shade300), // Border color
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide(
                              color: Colors.grey.shade300), // Border color
                        ),
                      ),
                      validator: validateName,
                      controller: nameController,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 25,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ReusableText(
                      title: "Category",
                      color: AppColor.textColor,
                      size: 12,
                      weight: FontWeight.bold,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    GestureDetector(
                      onTap: () {
                        showDialogForTypes();
                      },
                      child: TextFormField(
                        enabled: false,
                        validator: validateCategory,
                        controller: categoryController,
                        decoration: InputDecoration(
                          hintText: widget.category.toString(),
                          suffixIcon: const Icon(Icons.arrow_drop_down),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: const BorderSide(
                              color: Colors.grey,
                              width: 1.0,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 1.0,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 25,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ReusableText(
                      title: "Description",
                      color: AppColor.textColor,
                      size: 12,
                      weight: FontWeight.bold,
                    ),
                    const SizedBox(
                      height: 10,
                    ),

                    // ReusableTextForm(

                    //   validator: validateDescription,
                    //   controller: descriptionController,
                    //   hintText: "Type Here",
                    // )

                    TextFormField(
                      validator: validateDescription,
                      controller: descriptionController,
                      maxLength: 500,
                      decoration: InputDecoration(
                        hintText: widget.description,
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          borderSide: BorderSide(
                              color: Colors.grey.shade300, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          borderSide: BorderSide(
                              color: Colors.grey.shade300, width: 2.0),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 1.0),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          borderSide:
                              const BorderSide(color: Colors.red, width: 2.0),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          borderSide:
                              const BorderSide(color: Colors.red, width: 2.0),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 25,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ReusableText(
                      title: "Discount Percent",
                      color: AppColor.textColor,
                      size: 12,
                      weight: FontWeight.bold,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      // validator: (value) {
                      //   if (value == null || value.isEmpty) {
                      //     return "Discount should not be empty";
                      //   } else if (!RegExp(r'^[0-9]*$').hasMatch(value)) {
                      //     return "Please enter digits only";
                      //   }
                      //   return null;
                      // },
                      controller: discountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        hintText: widget.discount.toString(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: const BorderSide(
                            color: Colors.grey,
                            width: 1.0,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 1.0,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 25,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ReusableText(
                      title: "Discount End Date ",
                      color: AppColor.textColor,
                      size: 12,
                      weight: FontWeight.bold,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    GestureDetector(
                      onTap: () {
                        selectDate(context, 0);
                      },
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Discount End Date";
                          }

                          return null;
                        },
                        controller: dateController,
                        enabled: false,
                        decoration: InputDecoration(
                          hintText: widget.discountenddate,
                          suffixIcon: const Icon(
                            Icons.calendar_month_outlined,
                            color: AppColor.primaryColor,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: const BorderSide(
                              color: Colors.grey,
                              width: 1.0,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 1.0,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 1.0,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 25,
                ),
                isLoading
                    ? const CircularProgressIndicator(
                        color: AppColor.blackColor,
                      )
                    : ReusableButton(
                        title: "Update Business",
                        onTap: () {
                          // if (_formKey.currentState!.validate()) {}
                          updateBusiness();
                        }),
                const SizedBox(
                  height: 20,
                )
              ],
            ),
          ),
        ),
      )),
    );
  }

  showDialogForTypes() {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            titlePadding: EdgeInsets.zero,
            title: titleForDialog(context, 'Select Category'),
            content: Container(
              // height: 200,
              width: 350,
              child: ListView.builder(
                  shrinkWrap: true,
                  physics: const ScrollPhysics(),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      child: Column(
                        children: [
                          Text(
                            //"fdlkjfkjdhjk"
                            categories[index].Category.toString(),
                          ),
                          const Divider(),
                        ],
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        categoryController.text =
                            categories[index].Category.toString();
                        setState(() {});
                        print(
                            "Tapped ${categories[index].Category.toString()}");
                      },
                    );
                  }),
            ),
          );
        });
  }

  Widget openGallery() {
    return Container(
      height: 100.0,
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          const Text(
            "Chose profile photo",
            style: TextStyle(color: Colors.black, fontSize: 14),
          ),
          const SizedBox(
            height: 15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MaterialButton(
                onPressed: () {
                  takePhoto(
                    ImageSource.camera,
                  );
                  Navigator.pop(context);
                },
                child: const Row(
                  children: [
                    Text("Camera "),
                    SizedBox(
                      width: 5,
                    ),
                    Icon(Icons.camera_alt),
                  ],
                ),
              ),
              MaterialButton(
                onPressed: () {
                  takePhoto(ImageSource.gallery);
                  Navigator.pop(context);
                },
                child: const Row(
                  children: [
                    Text("Gallery "),
                    SizedBox(
                      width: 5,
                    ),
                    Icon(Icons.image),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void takePhoto(ImageSource source) async {
    final pickedFile = await ImagePicker().getImage(
      source: source,
    );
    if (pickedFile != null) {
      setState(() {
        imageFile = pickedFile;
        uploadFile();
        final bytes = Io.File(imageFile!.path).readAsBytesSync();

        // String img64 = base64Encode(bytes);
        // print(img64.substring(0, 100));
      });
    }
  }

  selectDate(BuildContext context, int index) async {
    DateTime? selectDate;
    await DatePicker.showDatePicker(context,
        showTitleActions: true, onChanged: (date) {}, onConfirm: (date) {
      selectDate = date;
    }, currentTime: DateTime.now());
    if (selectDate != null) {
      setState(() {
        if (index == 0) {
          dateController.text =
              DateFormat('dd-MM-yyyy KK:MM a').format(selectDate!);
        }
      });
    }
  }

  //Function for uploading picture to firestore
  Future uploadFile() async {
    setState(() {
      isLoadFile = true;
    });
    if (imageFile == null) return;
    final fileName = Path.basename(imageFile!.path);
    final destination = 'files/$fileName';

    task = FirebaseApi.uploadFile(destination, File(imageFile!.path));
    setState(() {});

    if (task == null) return;

    final snapshot = await task!.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();

    print('Download-Link: $urlDownload');
    firebasePictureUrl = urlDownload;
    setState(() {
      isLoadFile = false;
    });
  }
}
