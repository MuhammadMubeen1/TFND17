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
import 'package:tfnd_app/themes/color.dart';
import 'package:tfnd_app/widgets/reusable_button.dart';
import 'package:tfnd_app/widgets/reusable_text.dart';
import 'dart:io' as Io;

class addBusiness extends StatefulWidget {
  String useremail;
  addBusiness({super.key, required this.useremail});

  @override
  State<addBusiness> createState() => _addBusinessState();
}

class _addBusinessState extends State<addBusiness> {
  PickedFile? imageFile;

  UploadTask? task;
  String? firebasePictureUrl;
  bool isLoadFile = false;
  int? id;
  List<BusinessList> categories = [];

  TextEditingController nameController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController discountController = TextEditingController();

    FocusNode Namefocus = FocusNode(); 
    FocusNode cataFocusNode = FocusNode();
  FocusNode DesFocusNode = FocusNode();
    FocusNode DisFocusNode = FocusNode();
   FocusNode endDatefocusnode = FocusNode();
             
 void dispose() {
    nameController.dispose();
    categoryController.dispose();
    descriptionController.dispose();
    dateController.dispose();
    discountController.dispose();
    super.dispose();
  }


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
  // Parse the value to ensure it's a valid number
  int? discountValue = int.tryParse(value);
  
  // Check if the parsed value is null or not between 0 and 100
  if (discountValue == null || discountValue < 0 || discountValue > 100) {
    return "Discount should be between 0 and 100";
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
  }

  int numberOfCollections = 3;
  BusinessRegister() async {
    isLoading = true;
    setState(() {});

    id = DateTime.now().millisecondsSinceEpoch;

    AddBusinessModel dataModel = AddBusinessModel(
      name: nameController.text,
      category: categoryController.text,
      image: firebasePictureUrl,
      description: descriptionController.text,
      discount: discountController.text,
      date: dateController.text,
      clickCount: 0,
      uid: id,
      email: widget.useremail,
    );

    try {
      await FirebaseFirestore.instance
          .collection("BusinessRegister")
          .doc('$id')
          .set(dataModel.toJson());

      // Add business to user-specific collection
      await FirebaseFirestore.instance
          .collection("BusinessRegister")
          .doc(widget.useremail)
          .collection("Businesses")
          .doc('$id')
          .set(dataModel.toJson());

      // Create an additional collection inside $id

      isLoading = false;
      setState(() {});
      Fluttertoast.showToast(
        backgroundColor:AppColor.btnColor,

        msg: 'Business Created Successfully',
        textColor: AppColor.blackColor
        
         );
      Navigator.pop(context);
    } catch (e) {
      isLoading = false;
      setState(() {});
      Fluttertoast.showToast(
           backgroundColor:AppColor.btnColor,
        
        msg: 'Some Error Occurred',   textColor: AppColor.blackColor);
    }
  }

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
        iconTheme: const IconThemeData(
          color: AppColor.hintColor,
        ),
        centerTitle: true,
        title: const ReusableText(
          title: "Add Business",
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
                isLoadFile
                    ? const CircularProgressIndicator(
                        color: AppColor.blackColor,
                      )
                    : Center(
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
                                      border: Border.all(
                                          color: AppColor.primaryColor)),
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
              
                    TextFormField(
                      focusNode:Namefocus ,
                     onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(cataFocusNode);
                          showDialogForTypes();
                        },
                      maxLength: 25,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        hintText: "Type Here",
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
                        focusNode: cataFocusNode,
                        onFieldSubmitted: (_)
                        {
                             FocusScope.of(context).requestFocus(DesFocusNode);

                        },
                  
                        enabled: false,
                        validator: validateCategory,
                        controller: categoryController,
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          hintText: "Select Here",
                          suffixIcon: const Icon(Icons.arrow_drop_down),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: const BorderSide(
                              color: Colors.white,
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
                        
                         enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          borderSide: BorderSide(
                              color: Colors.grey.shade300, width: 1.0),
                        ),
                      
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          borderSide:
                             const BorderSide(color: Colors.white, width: 1.0),
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

                    TextFormField(
                      focusNode: DesFocusNode,
                         onFieldSubmitted: (_)
                        {
                              FocusScope.of(context).requestFocus(DisFocusNode);

                        },
                       
                      validator: validateDescription,
                      controller: descriptionController,
                      maxLength: 500,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        hintText: 'Type here',
                        border:const OutlineInputBorder(),
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
                             const BorderSide(color: Colors.white, width: 1.0),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          borderSide: const BorderSide(color: Colors.red, width: 2.0),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          borderSide:const  BorderSide(color: Colors.red, width: 2.0),
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
                        onFieldSubmitted: (_)
                        {
                              FocusScope.of(context).requestFocus( endDatefocusnode);
                              selectDate(context, 0);

                        },
                      focusNode: DisFocusNode ,
                      validator:validateDiscount, 
                      controller: discountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        hintText: "0%",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: const BorderSide(
                            color: Colors.white,
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
                      
                       enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          borderSide: BorderSide(
                              color: Colors.grey.shade300, width: 1.0),
                        ),
                      
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          borderSide:
                             const BorderSide(color: Colors.white, width: 1.0),
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

                       
                        focusNode: endDatefocusnode,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Discount End Date";
                          }

                          return null;
                        },
                        controller: dateController,
                        enabled: false,
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          hintText: "Pick Date",
                          suffixIcon: const Icon(
                            Icons.calendar_month_outlined,
                            color: AppColor.primaryColor,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                           borderSide: const BorderSide(
                              color: Colors.white,
                              width: 0.5,
                            ), 
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: const BorderSide(
                              color: Colors.white,
                              width: 0.5,
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
                     
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          borderSide: BorderSide(
                              color: Colors.grey.shade300, width: 1.0),
                        ),
                       
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          borderSide:
                             const BorderSide(color: Colors.white, width: 1.0),
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
                        title: "Publish",
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            BusinessRegister();
                          }
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
            titleTextStyle: TextStyle(color: AppColor.blackColor),
            title: titleForDialog(context, 'Select Category',),
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
            style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
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
                    Icon(Icons.camera_alt, color: AppColor.btnColor,),
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
                    Icon(Icons.image, color: AppColor.btnColor,),
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
            DateFormat('dd MMMM yyyy').format(selectDate!);
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
