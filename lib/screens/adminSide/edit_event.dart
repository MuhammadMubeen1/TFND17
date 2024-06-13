import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as Path;
import 'package:tfnd_app/models/BusinessCategory.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tfnd_app/widgets/const.dart';

import 'package:tfnd_app/themes/color.dart';
import 'package:tfnd_app/widgets/reusable_button.dart';
import 'package:tfnd_app/widgets/reusable_text.dart';
import 'dart:io' as Io;

class Editevent extends StatefulWidget {
  String useremail,
      eventname,
      date,
      description,
      time,
      price,
      uid,
      address,
      image,
      slots;
  final VoidCallback onDeleteSucces;
  Editevent({
    super.key,
    required this.useremail,
    required this.uid,
    required this.image,
    required this.eventname,
    required this.address,
    required this.description,
    required this.price,
    required this.time,
    required this.slots,
    required this.date,
    required this.onDeleteSucces,
  });

  @override
  State<Editevent> createState() => _addBusinessState();
}

class _addBusinessState extends State<Editevent> {
  PickedFile? imageFile;
  UploadTask? task;
  String? firebasePictureUrl;
  bool isLoadFile = false;
  int? id;
  LatLng? _currentLocation;
  LatLng? _pickedLocation;

  void _onLocationConfirmed() {
    Navigator.of(context).pop(_pickedLocation);
  }

  List<BusinessList> categories = [];
  TextEditingController nameController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController slotcontrollor = TextEditingController();
    final ScrollController _scrollController = ScrollController();

  void dispose() {
    nameController.dispose();
    dateController.dispose();
    descriptionController.dispose();
    timeController.dispose();
    priceController.dispose();
    addressController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showTimePicker() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      useRootNavigator: false, // Set useRootNavigator to false
    );

    if (pickedTime != null) {
      final String formattedTime =
          "${pickedTime.hourOfPeriod}:${pickedTime.minute} ${pickedTime.period == DayPeriod.am ? 'AM' : 'PM'}";
      timeController.text = formattedTime;
    }
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
    _getCurrentLocation();
    getCategories();
    print(' user is ${widget.useremail} ');
    print('edit id   ${widget.uid.toString()}');

    nameController.text = widget.eventname.toString();
    priceController.text = widget.price.toString();
    descriptionController.text = widget.description.toString();
    dateController.text = widget.date.toString();
    addressController.text = widget.address.toString();
    timeController.text = widget.time.toString();
    slotcontrollor.text = widget.slots.toString();
  }

  Future<void> updateBusiness() async {
    isLoading = true;
    setState(() {});

    try {
      // Extract updated data from form fields
      String newName = nameController.text.trim();
      String newprice = priceController.text.trim();
      String newDescription = descriptionController.text.trim();
      String newdate = dateController.text.trim();
      String newaddress = addressController.text.trim();
      String timeddress = timeController.text.trim();
      String slots = slotcontrollor.text.trim();

      // Check if a new image has been selected
      String? updatedImage;
      if (imageFile != null) {
        await uploadFile(); // Upload the new image
        updatedImage = firebasePictureUrl; // Get the updated image URL
      } else {
        updatedImage = widget.image; // Keep the existing image URL
      }

      // Update the business details in Firstore
      await FirebaseFirestore.instance
          .collection('adminevents')
          .doc(widget.uid.toString())
          .update({
        'name': newName,
        "slot": slots,
        'date': newdate,
        'discription': newDescription,
        'price': newprice,
        'image': updatedImage,
        'time': timeddress,
        'location': newaddress

        // Update th imaga URL
        // Add other fields as needed
      });

      isLoading = false;
      setState(() {});
      // Show a success message
      Fluttertoast.showToast(msg: 'Event details updated successfully', textColor: Colors.black, backgroundColor: AppColor.btnColor);
      Navigator.pop(context, true);
    } catch (e) {
      isLoading = false;
      setState(() {});
      // Handle any errors
      print('Error updating business: $e');
      // Show an error message
      Fluttertoast.showToast(
          msg: 'Failed to update business. Please try again.',textColor: Colors.black, backgroundColor: AppColor.btnColor);

      // Hide the loading bar after update is complete
      setState(() {
        isLoadFile = false;
      });
    }
  }

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

  void _getCurrentLocation() async {
    Location location = Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    setState(() {
      _currentLocation = LatLng(
        _locationData.latitude!,
        _locationData.longitude!,
      );
    });
  }
    FocusNode eventName = FocusNode(); 
    FocusNode DescriptionFocusNode = FocusNode();
  FocusNode priceFocusNode = FocusNode();
    FocusNode slotFocusNode = FocusNode();
        

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.bgColor,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(
          color: AppColor.hintColor,
        ),
        centerTitle: true,
        title: const ReusableText(
          title: "Edit Event ",
          color: AppColor.blackColor,
          size: 20,
          weight: FontWeight.w500,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            widget.onDeleteSucces(); // Navigate back to event details screen
          },
        ),
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            controller: _scrollController ,
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
                                title: "Add Event Image",
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
                  height: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ReusableText(
                      title: "Event Name",
                      color: AppColor.textColor,
                      size: 12,
                      weight: FontWeight.bold,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      focusNode: eventName ,
                   onFieldSubmitted:   (_) {
                      FocusScope.of(context).requestFocus(DescriptionFocusNode);
                    },
                   
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
                        fillColor: Colors.white,
                        filled: true,
                      ),
                      validator: validateName,
                      controller: nameController,
                    ),
                  ],
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
                      focusNode: DescriptionFocusNode,
                        onFieldSubmitted:   (_) {
                      FocusScope.of(context).requestFocus(priceFocusNode);
                    }, 
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
                        fillColor: Colors.white,
                        filled: true,
                      ),
                    )
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ReusableText(
                      title: "Price",
                      color: AppColor.textColor,
                      size: 12,
                      weight: FontWeight.bold,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      focusNode: priceFocusNode,
                         onFieldSubmitted:   (_) {
                      FocusScope.of(context).requestFocus(slotFocusNode);
                    },
                      maxLength: 6,
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        hintText: widget.price.toString(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                        fillColor: Colors.white,
                        filled: true,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ReusableText(
                      title: "Slots",
                      color: AppColor.textColor,
                      size: 12,
                      weight: FontWeight.bold,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      focusNode: slotFocusNode,
                      maxLength: 6,
                      controller: slotcontrollor,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        hintText: widget.price.toString(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                        fillColor: Colors.white,
                        filled: true,
                      ),
                    ),
                  ],
                ),
              const   SizedBox(
                  height: 15,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ReusableText(
                      title: "Event Time",
                      color: AppColor.textColor,
                      size: 12,
                      weight: FontWeight.bold,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    GestureDetector(
                      onTap: () {
                        _showTimePicker();
                      },
                      child: TextFormField(
                        style: const TextStyle(color: Colors.black),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return "Time should not be Empty";
                          } else {
                            return null;
                          }
                        },
                        controller: timeController,
                        enabled: false,
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          hintText: "Pick Time",
                          suffixIcon: const Icon(
                            Icons.alarm_outlined,
                            color: AppColor.primaryColor,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
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
                      title: "Date ",
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
                        style: const TextStyle(color: Colors.black),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return " Date";
                          }

                          return null;
                        },
                        controller: dateController,
                        enabled: false,
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          hintText: widget.date,
                          suffixIcon: const Icon(
                            Icons.calendar_month_outlined,
                            color: AppColor.primaryColor,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                   const  SizedBox(
                      height: 15,
                    ),
                    const ReusableText(
                      title: "Event Location",
                      color: AppColor.textColor,
                      size: 12,
                      weight: FontWeight.bold,
                    ),
                   const  SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      readOnly: true,
                      style: const TextStyle(color: Colors.black),
                      controller: addressController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                              color: Colors.white,
                              width: 1.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                              color: Colors.white,
                              width: 1.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                              color: Colors.white,
                              width: 2.0,
                            ),
                          ),
                          hintText: 'Pick Location',
                          hintStyle: const TextStyle(color: Colors.grey),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              showPlacePicker();
                            },
                            child: const Icon(
                              Icons.location_on,
                              color: AppColor.pinktextColor,
                              size: 25,
                            ),
                          ),
                          fillColor: Colors.white,
                          filled: true),
                    ),
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
                        title: "Update Event",
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
    DateTime? selectedDate;
    await DatePicker.showDatePicker(
      context,
      showTitleActions: true,
      onChanged: (date) {},
      onConfirm: (date) {
        selectedDate = date;
      },
      currentTime: DateTime.now(),
      locale: LocaleType.en, // Set the locale to English for month names
    );
    if (selectedDate != null) {
      setState(() {
        if (index == 0) {
          dateController.text =
              DateFormat('dd MMMM yyyy').format(selectedDate!);
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

  void showPlacePicker() async {
    if (_currentLocation != null) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return PlacePicker(
              apiKey: "AIzaSyAlWLuEzszKgldMmuo9JjtKLxe9MGk75_k",
              hintText: "Select Location",
              searchingText: "Please wait ...",
              selectText: "Select place",
              outsideOfPickAreaText: "Place is not in area",
              initialPosition: _currentLocation!,
              selectInitialPosition: true,
              onPlacePicked: (result) {
                addressController.text = result.formattedAddress!;
                print(result);
                Navigator.of(context).pop();
                setState(() {});
              },
            );
          },
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColor.btnColor,
          content: Text(
            
              "Could not get current location. Please make sure location services are enabled.", style: TextStyle(color: Colors.black),),
        ),
      );
    }
  }
}
