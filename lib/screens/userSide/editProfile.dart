import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tfnd_app/Controllors/signup_controllor.dart';

import 'package:tfnd_app/themes/color.dart';
import 'package:tfnd_app/widgets/country_picker.dart';
import 'package:tfnd_app/widgets/reusable_textformfield.dart';
import 'package:tfnd_app/widgets/reuseable_dropdown.dart';

class Editprofile extends StatefulWidget {
  final String eamil,
      phonenumber,
      name,
      password,
      image,
      state,
      nationality,
      location,
      Conterrr,
      Industreis,
      phonecode,
      comlete;
  Editprofile({
    Key? key,
    required this.eamil,
    required this.comlete,
    required this.phonecode,
    required this.phonenumber,
    required this.name,
    required this.password,
    required this.image,
    required this.state,
    required this.nationality,
    required this.location,
    required this.Conterrr,
    required this.Industreis,
  }) : super(key: key);

  @override
  State<Editprofile> createState() => _ProfileBarState();
}

class _ProfileBarState extends State<Editprofile> {
  final TextEditingController _nameController = TextEditingController();
  String? selectedPhoneNumber;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  TextEditingController _statecontrollor = TextEditingController();
  final TextEditingController _nationality = TextEditingController();
  final TextEditingController _loction = TextEditingController();
  final TextEditingController _Country = TextEditingController();
  final TextEditingController _industries = TextEditingController();
  final ScrollController _scrollController = ScrollController(); 
 String? _phonecode; 
  bool isLoading = false;
  PickedFile? imageFile;
  String profilePicUrl = "";
  String?   _complte;
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  
    _nationality.dispose();

    _Country.dispose();
    _industries.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  @override
  void initState(){
  super.initState();
    // Initialize controllers with existing data
    _nameController.text = widget.name;
    _phonecode=widget.phonecode.toString();
    _complte=widget.comlete;
    selectedPhoneNumber = widget.phonenumber;
    _emailController.text = widget.eamil.toString();
    _passwordController.text = widget.password;
    profilePicUrl = widget.image;
    _statecontrollor.text = widget.state;
    _nationality.text = widget.nationality;
    _loction.text = widget.location;
    _Country.text = widget.Conterrr;
    _industries.text = widget.Industreis;
  }

  final List<String> _uaeStates = [
    'Abu Dhabi',
    'Dubai',
    'Sharjah',
    'Ajman',
    'Umm Al Quwain',
    'Ras Al Khaimah',
    'Fujairah'
  ];

  int suggestionsCount = 21; // Initial count of suggestions
  int counter = 0;
  String? _selectedState;
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
 FocusNode fullName = FocusNode(); 
    FocusNode phoneFocusNode = FocusNode();

    FocusNode locationFocusNode = FocusNode();
   
            FocusNode NationalityNode = FocusNode();
               FocusNode expertiesNode = FocusNode();

  FocusNode passwordFocusNode = FocusNode();
  FocusNode confirmPasswordFocusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.bgColor,
        centerTitle: true,
        title: const Text(
          "Edit Profile",
          style: TextStyle(
              color: AppColor.blackColor,
              fontSize: 20,
              fontWeight: FontWeight.w500),
        ),
        actions: [],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
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
                          borderRadius: BorderRadius.circular(600),
                          child: Container(
                            height: 140,
                            width: 140,
                            child: (imageFile != null)
                                ? Image.file(
                                    File(imageFile!.path),
                                    fit: BoxFit.cover,
                                  )
                                : (profilePicUrl.isEmpty
                                    ? Image.asset(
                                        'assets/images/tfndlog.jpg',
                                        fit: BoxFit.cover,
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
                const SizedBox(height: 15),
                ReusableTextForm(
                  focusNode:  fullName,
                  controller: _nameController,
                  hintText: "Name",
                    onSubmitted: (_) {
                      FocusScope.of(context).requestFocus(phoneFocusNode);
                    },
                  prefixIcon: const Icon(
                    Icons.person_outlined,
                    color: AppColor.hintColor,
                  ),



                ),
                const SizedBox(height: 10),
                IntlPhoneField(
                  focusNode: phoneFocusNode ,
                   onSubmitted: (_) {
                      FocusScope.of(context).requestFocus(locationFocusNode);
                    },
                  onChanged: (phoneNumber) {
                  

                     setState(() {
           _phonecode = phoneNumber.number;
          selectedPhoneNumber = phoneNumber.countryISOCode;
            _complte = phoneNumber.completeNumber;
        });
                  
                  },
                  initialCountryCode:selectedPhoneNumber,
                  flagsButtonPadding: const EdgeInsets.all(8),
                  dropdownIconPosition: IconPosition.trailing,
                  decoration: InputDecoration(
                    contentPadding:
                       const  EdgeInsets.symmetric(vertical: 23, horizontal: 20),
                    filled: true,
                    fillColor: Colors.white, // labelText: 'Phone Number',
                    hintText: widget.phonecode,
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
                ),
                const SizedBox(height: 10),
                ReusableTextForm(
                
                  readOnly: true,
                  controller: _emailController,
                  hintText: "Email",
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: AppColor.hintColor,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                    
                  focusNode:locationFocusNode ,

                  onSubmitted: (_) {
                      FocusScope.of(context).requestFocus(expertiesNode);
                    },
                  style: const TextStyle(
                    color: Colors.grey, // Change text color
                    // Change text size
                  ),
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    prefixIcon: const Icon(
                      Icons.location_on_outlined,
                      color: AppColor.hintColor,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                          18.0), // Adjust the value as needed
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.white, width: 2.0),
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.white, width: 1.0),
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                  ),
                  controller: _loction,
                  maxLines: null,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return "This field is required";
                    }
                  },
                  iconEnabledColor: AppColor.btnColor,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    hintText: 'City',
                    prefixIcon: const Icon(
                      Icons.location_city_outlined,
                      color: AppColor.hintColor,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                  ),
                  value: _statecontrollor.text,
                  items: _uaeStates.map((state) {
                    return DropdownMenuItem<String>(
                      value: state,
                      child: Text(
                        state,
                        style: TextStyle(color: AppColor.hintColor),
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _statecontrollor.text = newValue!;
                    });
                  },
                ),
            
            const    SizedBox(
                  height: 10,
                ),
                TextFormField(
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return "This field is required";
                      }
                    },
                    style:const  TextStyle(color: AppColor.hintColor),
                    controller: _Country,
                    readOnly: true,
                    decoration: InputDecoration(
                      fillColor:
                          Colors.white, // Ensure the fillColor is set to white
                      filled: true, // Set the filled property to true
                      hintText: 'Country',
                      hintStyle: const TextStyle(color: AppColor.hintColor),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(top: 13, left: 12),
                        child: FaIcon(
                          FontAwesomeIcons.globe,
                          color: Colors.grey,
                          size: 20.0,
                        ),
                      ),

                    
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                    ),
                    onTap: () {
                      
                    }),
              const  SizedBox(
                  height: 20,
                ),

                            ReusableCountryPickerFormField(
                  controller:   _nationality,
                  hintText: 'Nationality',
                  onSelect: (Country country) {
                    setState(() {
                      String countryName = country.name;
                    _nationality.text = countryName;
                    });
                    print('Selected country: ${country.name}');
                  },),
                       const   SizedBox(
                  height: 10,
                ), 
                CustomSearchField(
                  focusNode: expertiesNode,
                  suggestions: suggestions,
                  hint: 'Search industries...',
                  onSuggestionAdded: () {
                    setState(() {
                      suggestionsCount++;
                      counter++;
                      suggestions.add('suggestion $suggestionsCount');
                    });
                  },
                  icon: const Icon(
                    Icons.search_outlined,
                    color: AppColor.hintColor,
                  ),
                  controller: _industries,
                ),
               const SizedBox(
                  height: 20,
                ),
                Container(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.btnColor,
                      textStyle: const TextStyle(fontSize: 18),
                      minimumSize: const Size.fromHeight(50),
                    ),
                    onPressed: isLoading
                        ? null // Disable button if loading
                        : () async {
                            setState(() {
                              isLoading =
                                  true; // Set isLoading to true immediately
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              
                              const SnackBar(
                                backgroundColor: AppColor.btnColor,
                                content: Text('Please wait...!', style: TextStyle(color: AppColor.blackColor),),
                              ),
                            );
                            if (imageFile != null) {
                              await uploadProfilePicture();
                            }
                            updateUserProfile();
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
                            "Update Profile",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              const  SizedBox(
                  height: 30,
                ),
              ],
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
            style: TextStyle(
                color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
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
                    Icon(
                      Icons.camera_alt,
                      color: AppColor.btnColor,
                    ),
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
                    Text(
                      "Gallery ",
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Icon(Icons.image, color: AppColor.btnColor),
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

  Future<void> uploadProfilePicture() async {
    try {
      String downloadUrl = await uploadImageToStorage(imageFile!.path);
      setState(() {
        profilePicUrl = downloadUrl;
      });
    } catch (error) {
      print('Error uploading profile picture: $error');
      // Handle error as needed
    }
  }

  Future<void> updateUserProfile() async {
    setState(() {
      isLoading = true;
    });

    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('RegisterUsers')
          .where('email', isEqualTo: widget.eamil.toString())
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        await doc.reference.update({
          'name': _nameController.text.isEmpty || _nameController.text == null
              ? widget.name
              : _nameController.text,
          'phoneNumber':
              selectedPhoneNumber!.isEmpty || selectedPhoneNumber == null
                  ? widget.phonenumber
                  : selectedPhoneNumber,
                   'phonecode':
            _phonecode!.isEmpty || _phonecode == null
                  ? widget.phonecode
                  : _phonecode,
          'email':
              _emailController.text.isEmpty || _emailController.text == null
                  ? widget.eamil
                  : _emailController.text,
          'password': _passwordController.text.isEmpty ||
                  _passwordController.text == null
              ? widget.password
              : _passwordController.text,
          'image': profilePicUrl,
          'Location': _loction.text.isEmpty || _loction.text == null
              ? widget.location
              : _loction.text,
          'State':
              _statecontrollor.text.isEmpty || _statecontrollor.text == null
                  ? widget.state
                  : _statecontrollor.text,
          'Nationality': _nationality.text.isEmpty || _nationality.text == null
              ? widget.nationality
              : _nationality.text,
          'Countryyy': _Country.text.isEmpty || _Country.text == null
              ? widget.Conterrr
              : _Country.text,
          'industeries': _industries.text.isEmpty || _industries.text == null
              ? widget.Industreis
              : _industries.text,

                  'completenumber': _complte!.isEmpty || _complte == null
              ? widget.comlete
              : _complte,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColor.btnColor,
            content: Text('Profile updated successfully!', style: TextStyle(color: AppColor.blackColor),),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
             backgroundColor: AppColor.btnColor,
            content: Text('User not found!', style: TextStyle(color: AppColor.blackColor)),
          ),
        );
      }
    } catch (error) {
      print('Error updating profile: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
              backgroundColor: AppColor.btnColor,
          content: Text('Failed to update profile. Please try again.', style: TextStyle(color: AppColor.blackColor)),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
