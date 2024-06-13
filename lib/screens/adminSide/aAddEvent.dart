import 'dart:io';
import 'dart:io' as Io;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:tfnd_app/Controllors/signup_controllor.dart';
import 'package:tfnd_app/widgets/const.dart';
import 'package:tfnd_app/models/AddEventModel.dart';
import 'package:tfnd_app/themes/color.dart';
import 'package:tfnd_app/widgets/reusable_button.dart';
import 'package:tfnd_app/widgets/reusable_text.dart';
import 'package:tfnd_app/widgets/reusable_textformfield.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:path/path.dart' as Path;
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';

class aAddEvent extends StatefulWidget {
  const aAddEvent({super.key});

  @override
  State<aAddEvent> createState() => _aAddEventState();
}

class _aAddEventState extends State<aAddEvent> {
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

  TextEditingController nameController = TextEditingController();
  TextEditingController dicriptioncontrollor = TextEditingController();
  TextEditingController totalseatscontrollor = TextEditingController();
  TextEditingController pricecontrollor = TextEditingController();
  final initialPosition = LatLng(40.7128, -74.0060);

  TextEditingController locationController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  PickedFile? imageFile;
  GoogleMapController? _mapController;
  LatLng? _currentLocation;
  LatLng? _pickedLocation;

  void _onLocationConfirmed() {
    Navigator.of(context).pop(_pickedLocation);
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
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

  UploadTask? task;
  String? firebasePictureUrl;
  bool isLoadFile = false;

  EventRegister() async {
    isLoading = true;
    setState(() {});
    int id = DateTime.now().millisecondsSinceEpoch;
    AddEventModel dataModel = AddEventModel(
      name: nameController.text,
      discription: dicriptioncontrollor.text,
      slot: totalseatscontrollor.text,
      remaining: totalseatscontrollor.text,
      price: pricecontrollor.text,
      Location: locationController.text,
      image: firebasePictureUrl,
      date: dateController.text,
      time: timeController.text,
      uid: id,
      booked: "0",
      revenue: "0"
    );
    try {
      await FirebaseFirestore.instance
          .collection('adminevents') // Use the collection name 'adminevents'
          .doc('$id')
          .set(dataModel.toJson());
      isLoading = false;
      setState(() {});
      Fluttertoast.showToast(
        backgroundColor: AppColor.btnColor,
        textColor: Colors.black,
        msg: 'Event Created Successfully');
      Navigator.pop(context);
    } catch (e) {
      isLoading = false;
      setState(() {});
      Fluttertoast.showToast(
        
         backgroundColor: AppColor.btnColor,
        textColor: Colors.black,
        msg: 'Some Error Occurred');
    }
  }

  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

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
          content: Text(
              "Could not get current location. Please make sure location services are enabled."),
        ),
      );
    }
  }
 FocusNode Namefocused = FocusNode(); 
    FocusNode DesFocusNode = FocusNode();
  FocusNode slotsFocusNode = FocusNode();
    FocusNode priceFocusNode = FocusNode();
         FocusNode DateNode = FocusNode();
            FocusNode TimeNode = FocusNode();
               FocusNode LocationNode = FocusNode();
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
          title: "Add Event",
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
            controller: _scrollController,
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
                  height: 25,
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
                    ReusableTextForm(
                      focusNode:  Namefocused ,
                       onSubmitted: (_) {
                      FocusScope.of(context).requestFocus(DesFocusNode);
                    },
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return "Name should not be Empty";
                        } else {
                          return null;
                        }
                      },
                      controller: nameController,
                      hintText: "Type Here",
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
                      title: "Description",
                      color: AppColor.textColor,
                      size: 12,
                      weight: FontWeight.bold,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ReusableTextForm(
                      focusNode: DesFocusNode,
                       onSubmitted: (_) {
                      FocusScope.of(context).requestFocus(slotsFocusNode);
                    },
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return "Description should not be Empty";
                        } else {
                          return null;
                        }
                      },
                      controller: dicriptioncontrollor,
                      hintText: "Type Here", 
                    )
                  ],
                ),
                const SizedBox(
                  height: 25,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const ReusableText(
                            title: "Total Slots",
                            color: AppColor.textColor,
                            size: 12,
                            weight: FontWeight.bold,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            focusNode: slotsFocusNode,
                   onFieldSubmitted:        (_) {
                      FocusScope.of(context).requestFocus(priceFocusNode);
                    }, 
                            maxLength: 6,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return " Empty";
                              } else if (!RegExp(r'^[0-9]*$').hasMatch(value)) {
                                return "Please enter digits only";
                              }
                              return null;
                            },
                            controller: totalseatscontrollor,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            // Set keyboard appearance to light
                            keyboardAppearance: Brightness.light,
                            decoration: InputDecoration(
                              hintText: "Slots",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18.0),
                                borderSide:
                                    const BorderSide(color: Colors.white),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18.0),
                                borderSide:
                                    const BorderSide(color: Colors.white),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18.0),
                                borderSide:
                                    const BorderSide(color: Colors.white),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18.0),
                                borderSide:
                                    const BorderSide(color: Colors.white),
                              ),
                              fillColor: Colors.white,
                              filled: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: Column(
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
                             onFieldSubmitted:        (_) {

                      FocusScope.of(context).requestFocus(DateNode );
  selectDate(context, 0);
                    }, 
                            maxLength: 6,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Empty";
                              } else if (!RegExp(r'^[0-9]*$').hasMatch(value)) {
                                return "Please enter digits only";
                              }
                              return null;
                            },
                            controller: pricecontrollor,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              fillColor: Colors.white,
                              hintText: "00",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18.0),
                                borderSide:
                                    const BorderSide(color: Colors.white),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18.0),
                                borderSide:
                                    const BorderSide(color: Colors.white),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18.0),
                                borderSide:
                                    const BorderSide(color: Colors.white),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18.0),
                                borderSide:
                                    const BorderSide(color: Colors.white),
                              ),
                              filled: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 25,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const ReusableText(
                            title: "Event Date",
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
                              focusNode: DateNode,
                               onFieldSubmitted:        (_) {
 _showTimePicker();
                      FocusScope.of(context).requestFocus(TimeNode);

                    }, 
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return "Date should not be Empty";
                                } else {
                                  return null;
                                }
                              },
                              controller: dateController,
                              enabled: false,
                              decoration: InputDecoration(
                                hintText: "Pick Date",
                                suffixIcon: const Icon(
                                  Icons.calendar_month_outlined,
                                  color: AppColor.primaryColor,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                  borderSide:
                                      const BorderSide(color: Colors.white),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                  borderSide:
                                      const BorderSide(color: Colors.white),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                  borderSide:
                                      const BorderSide(color: Colors.white),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                  borderSide:
                                      const BorderSide(color: Colors.white),
                                ),
                                fillColor: Colors.white,
                                filled: true,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: Column(
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
                              focusNode: TimeNode,
                             onFieldSubmitted:        (_) {

                      FocusScope.of(context).requestFocus(LocationNode);
 
                    },  
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
                                  hintText: "Pick Time",
                                  suffixIcon: const Icon(
                                    Icons.alarm_outlined,
                                    color: AppColor.primaryColor,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    borderSide:
                                        const BorderSide(color: Colors.white),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    borderSide:
                                        const BorderSide(color: Colors.white),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    borderSide:
                                        const BorderSide(color: Colors.white),
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    borderSide:
                                        const BorderSide(color: Colors.white),
                                  ),
                                  filled: true),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 25,
                ),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const ReusableText(
                    title: "Location",
                    color: AppColor.textColor,
                    size: 12,
                    weight: FontWeight.bold,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    focusNode: LocationNode,
                    readOnly: true,
                    style: const TextStyle(color: Colors.black),
                    controller: locationController,
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
                ]),
                const SizedBox(
                  height: 35,
                ),
                isLoading
                    ? const CircularProgressIndicator(
                        color: AppColor.blackColor,
                      )
                    : ReusableButton(
                        title: "Publish",
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            EventRegister();
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
                    Icon(Icons.image,color: AppColor.btnColor,),
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
    void dispose() {
    nameController.dispose();
    dicriptioncontrollor.dispose();
    totalseatscontrollor.dispose();
    pricecontrollor.dispose();
    locationController.dispose();
    dateController.dispose();
    timeController.dispose();
    _scrollController.dispose();
    Namefocused.dispose();
    DesFocusNode.dispose();
    slotsFocusNode.dispose();
    priceFocusNode.dispose();
    DateNode.dispose();
    TimeNode.dispose();
    LocationNode.dispose();
    super.dispose();
  }

}
