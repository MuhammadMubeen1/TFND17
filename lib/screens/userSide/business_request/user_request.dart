import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tfnd_app/themes/color.dart';
import 'package:tfnd_app/widgets/reusable_text.dart';
import 'package:tfnd_app/widgets/reusable_textformfield.dart';


class Requestform extends StatefulWidget {
  String emails;
  Requestform({Key? key, required this.emails}) : super(key: key);

  @override
  State<Requestform> createState() => _ProfileBarState();
}

class _ProfileBarState extends State<Requestform> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final initialPosition = LatLng(40.7128, -74.0060);
  String? selectedPhoneNumber; 
  bool isLoading = false;
  PickedFile? imageFile;
  String profilePicUrl = "";
  final _formKey = GlobalKey<FormState>();
  LatLng? _currentLocation;
 

 void dispose() {
    _nameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future onSelectNotification(String? payload) async {
    // Handle notification tap
    print("Notification tapped");
  }

  Future<String> uploadImageToStorage(String filePath) async {
    final Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('user_profile_pictures')
        .child('${DateTime.now().millisecondsSinceEpoch}');
    final UploadTask uploadTask = storageReference.putFile(File(filePath));
    final TaskSnapshot snapshot = await uploadTask;
    final String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> sendRequestToFirestore(String imageUrl) async {
    try {
      CollectionReference requestsCollection =
          FirebaseFirestore.instance.collection('requests');
 String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
 String currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
      DocumentReference requestDocument = await requestsCollection.add({
        'userName': _nameController.text,
        'phone': selectedPhoneNumber ?? "",
        'email': _emailController.text,
        'location': locationController.text,
        'imageUrl': imageUrl,
        'status': 'pending',
        'curentemail': widget.emails,
         'date': currentDate,
         'time':currentTime,
        // Initial status
      });

      String requestId = requestDocument.id;
      await requestDocument.update({'requestId': requestId});

      print('Request sent successfully with ID: $requestId');
    } catch (error) {
      print('Error sending request to Firestore: $error');
    }
  }

  void handleRequestStatus(String requestId, String status) async {
    try {
      CollectionReference requestsCollection =
          FirebaseFirestore.instance.collection('requests');

      await requestsCollection.doc(requestId).update({'status': status});

      if (status == 'approved') {
        // Show notification when the status is approved
      }

      print('Request $requestId $status successfully');
    } catch (error) {
      print('Error updating request status: $error');
    }
  }

  Future<void> uploadProfilePicture() async {
    try {
      if (imageFile == null) {
        // Show a Snackbar if the image is null
        Fluttertoast.showToast(
          msg: 'Please select a business image',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 1,
          backgroundColor: AppColor.btnColor,
          textColor: AppColor.blackColor,
          fontSize: 16.0,
        );
        return; // Exit the function if the image is null
      }

      String downloadUrl = await uploadImageToStorage(imageFile!.path);

      await sendRequestToFirestore(downloadUrl);

      // Show a Snackbar when the request is sent successfully
      Fluttertoast.showToast(
        msg: 'Request sent successfully. You will be notified.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: AppColor.blackColor,
        textColor: AppColor.btnColor,
        fontSize: 16.0,
      );

      // Clear the form fields
      _nameController.clear();
      _phoneNumberController.clear();
      _emailController.clear();
      locationController.clear();
      setState(() {
        imageFile = null;
      });

      Navigator.pop(context);
    } catch (error) {
      print('Error uploading profile picture: $error');
    }
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
      _currentLocation =
          LatLng(_locationData.latitude!, _locationData.longitude!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Add Business Request",
          style: TextStyle(
              color: AppColor.blackColor,
              fontSize: 20,
              fontWeight: FontWeight.w500),
        ),
        actions: [],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 15),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: ((builder) => openGallery()),
                      );
                    },
                    child: Center(
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Container(
                              height: 140,
                              width: double.infinity,
                              child: (imageFile != null)
                                  ? Image.file(
                                      File(imageFile!.path),
                                      fit: BoxFit.contain,
                                    )
                                  : (profilePicUrl.isEmpty
                                      ? Container(
                                          height: 150,
                                          width: 150,
                                          decoration: BoxDecoration(
                                              color: Colors.grey.shade200),
                                          child:   const Center(
                                            child: ReusableText(
                                              color: AppColor.btnColor,
                                           
                                              title: "Add Business Image",
                                            ),
                                          ),
                                        )
                                      : Image.network(
                                        
                                          profilePicUrl,
                                          fit: BoxFit.cover,

                                        )),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: ((builder) => openGallery()),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: AppColor.btnColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ReusableTextForm(
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return "Please enter business Name";
                      } else {
                        return null;
                      }
                    },
                    controller: _nameController,
                    hintText: "Business Name",
                    prefixIcon: const Icon(
                      Icons.person_outlined,
                      color: AppColor.hintColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                IntlPhoneField(
                    onChanged: (phoneNumber) {
                    selectedPhoneNumber = phoneNumber.completeNumber;
                  },
                  validator: validatePhoneNumber,
                 
                  flagsButtonPadding: const EdgeInsets.all(8),
                  dropdownIconPosition: IconPosition.trailing,
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 23, horizontal: 20),
                    filled: true,
                    fillColor: Colors.white, // labelText: 'Phone Number',
                    hintText: 'Business Phone',
                    border: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 1.0),
                        borderRadius: BorderRadius.all(Radius.circular(18))),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(
                          color: AppColor.borderFormColor, width: 1),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: Colors.red, width: 1),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: Colors.red, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(
                          color: AppColor.borderFormColor, width: 1),
                    ),
                  ),
                  style: TextStyle(),
                  initialCountryCode: 'AE',
               
                ),
                  const SizedBox(height: 20),
                  ReusableTextForm(
                    textCapitalization: TextCapitalization.none,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return "Please enter email";
                      } else {
                        return null;
                      }
                    },
                    controller: _emailController,
                    hintText: "Business Email",
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: AppColor.hintColor,
                    ), 
                  ),
                  const SizedBox(height: 20),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return "Please enter location";
                            } else {
                              return null;
                            }
                          },
                          onTap: () {
                            showPlacePicker();
                          },
                          readOnly: true,
                          style: const TextStyle(color: Colors.black),
                          controller: locationController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                color: Colors.grey,
                                width: 1.0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                color: Colors.grey,
                                width: 1.0,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                color: Colors.grey,
                                width: 2.0,
                              ),
                            ),
                            hintText: 'Pick Location',
                            hintStyle: const TextStyle(color: Colors.grey),
                            suffixIcon: const Icon(
                              Icons.location_on,
                              color: AppColor.btnColor,
                              size: 25,
                            ),
                          ),
                        ),
                      ]),
                  const SizedBox(height: 20),
                  Container(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.btnColor,
                        textStyle: const TextStyle(fontSize: 18),
                        minimumSize: const Size.fromHeight(50),
                      ),
                      onPressed: isLoading
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  isLoading = true;
                                });
                                await uploadProfilePicture();
                                setState(() {
                                  isLoading = false;
                                });
                              }
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
                              "Submit Business",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
            "Choose profile photo",
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
                  takePhoto(ImageSource.camera);
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
                    Text("Gallery ", ),
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
    final pickedFile = await ImagePicker().getImage(source: source);
    if (pickedFile != null) {
      setState(() {
        imageFile = pickedFile;
      });
    }
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
                locationController.text = result.formattedAddress!;
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
          backgroundColor: AppColor.blackColor,
          content: Text(
              "Could not get current location. Please make sure location services are enabled.", style: TextStyle(color: AppColor.btnColor,))

        ),
      );
    }
  }

   FutureOr<String?> validatePhoneNumber(PhoneNumber? value) {
    if (value == null || value.number.isEmpty) {
      return 'Phone number is required';
    }
    // You can add more specific validation logic here if needed
    return null; // Return null if validation succeeds
  }
}
