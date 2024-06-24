
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:country_picker/country_picker.dart';
import 'package:email_otp/email_otp.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tfnd_app/Controllors/signup_controllor.dart';
import 'package:tfnd_app/screens/auth/signin.dart';
import 'package:tfnd_app/themes/color.dart';
import 'package:tfnd_app/widgets/country_picker.dart';
import 'package:tfnd_app/widgets/dropdown_button.dart';
import 'package:tfnd_app/widgets/phonfield.dart';
import 'package:tfnd_app/widgets/privcy_police.dart';
import 'package:tfnd_app/widgets/reusable_button.dart';
import 'package:tfnd_app/widgets/reusable_text.dart';
import 'package:tfnd_app/widgets/reusable_textformfield.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tfnd_app/widgets/reuseable_dropdown.dart';
import 'package:url_launcher/url_launcher.dart';

class Signup extends StatefulWidget {
  String email;
   Signup({Key? key, required this.email}) : super(key: key);

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmpassController = TextEditingController();
  TextEditingController Nationalitycontroller = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController CountryControllor = TextEditingController();
  TextEditingController Searchcontrollor = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final SignupController _signupController = SignupController();
 

void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmpassController.dispose();
    Nationalitycontroller.dispose();
    locationController.dispose();
    CountryControllor.dispose();
    Searchcontrollor.dispose();
    _scrollController.dispose();
  
    super.dispose();
  }


   final TextEditingController _phoneController = TextEditingController();
  LatLng? _currentLocation;

  bool _passwordVisible = false;
  bool passwordVisible = false;
  bool isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  EmailOTP myauth = EmailOTP();
  String? industeries;
  String? completenumber;
  void setLoading(bool loading) {
    setState(() {
      isLoading = loading;
    });
  }
 
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  int suggestionsCount = 21; // Initial count of suggestions
  int counter = 0;
  String? _selectedState;

  final _formKey = GlobalKey<FormState>();
  
    FocusNode fullName = FocusNode(); 
    FocusNode phoneFocusNode = FocusNode();
  FocusNode emailFocusNode = FocusNode();
    FocusNode locationFocusNode = FocusNode();
         FocusNode CitNode = FocusNode();
            FocusNode NationalityNode = FocusNode();
               FocusNode expertiesNode = FocusNode();

  FocusNode passwordFocusNode = FocusNode();
  FocusNode confirmPasswordFocusNode = FocusNode();
  ///country code of the code
    String? countryCode ;
    String? selectedPhoneNumber ;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              controller:_scrollController,
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Container(
                  height: 200,
                  width: 200,
                  child: const Image(image: AssetImage("assets/images/tfndd.png")),
                ),
                const SizedBox(height: 10),
                const ReusableText(
                  title: "Sign Up",
                  color: AppColor.blackColor,
                  size: 27,
                  weight: FontWeight.bold,
                ),
                const SizedBox(height: 10),
                ReusableTextForm(
                onSubmitted: (_) {
                      FocusScope.of(context).requestFocus(phoneFocusNode);
                    },
                  focusNode: fullName,
                  controller: nameController,
                  hintText: "Full Name",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Name cannot be empty';
                    }
                    return null;
                  },
                  prefixIcon: const Icon(
                    Icons.person_outlined,
                    color: AppColor.hintColor,
                  ),
                ),
                const SizedBox(height: 20),

IntlPhoneField(
  
  
       decoration: InputDecoration(
                    contentPadding:
                       const  EdgeInsets.symmetric(vertical: 23, horizontal: 20),
                    filled: true,
                    fillColor: Colors.white, // labelText: 'Phone Number',
                    hintText: "Phone",
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
      initialCountryCode: 'AE',
      onChanged: (phone) {
        setState(() {
          countryCode = phone.number;
          selectedPhoneNumber = phone.countryISOCode;
          completenumber= phone.completeNumber;
        });
      },
),
  

                const SizedBox(
                  height: 10,
                ),
                ReusableTextForm(
         onSubmitted: (_) {
                      FocusScope.of(context).requestFocus(locationFocusNode);
                    },
            focusNode: emailFocusNode,
                  keyboardType: TextInputType.emailAddress,
                  textCapitalization: TextCapitalization.none,
                  controller: emailController,
                  hintText: "Email",
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return "This field is required";
                    } else if (!v.contains("@")) {
                      return "email badly formatted";
                    } else {
                      return null;
                    }
                  },
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: AppColor.hintColor,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  focusNode: locationFocusNode,
                  onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(CitNode);
                    },
                  maxLines: null,
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return "Please enter location";
                    }
                  },
                  onTap: () {},
                  style: TextStyle(color: AppColor.hintColor),
                  controller: locationController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      borderSide: const BorderSide(
                        color: Colors.white,
                        width: 1.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      borderSide: const BorderSide(
                        color: Colors.white,
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      borderSide: const BorderSide(
                        color: Colors.white,
                        width: 1.0,
                      ),
                    ),
                    hintText: 'Address',
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(
                      Icons.location_on_outlined,
                      color: AppColor.hintColor,
                      size: 25,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ReusableDropdown(
                onSubmitted: () {
                    FocusScope.of(context).requestFocus(NationalityNode);
                },
                focusNode: CitNode,
                         selectedValue: _selectedState,
                  hint: 'City',
                  prefixIcon: const Icon(
                    Icons.location_city_outlined,
                    color: AppColor.hintColor,
                  ),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedState = newValue;
                    });
                  },
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return "This field is required";
                    }
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                    style: TextStyle(color: AppColor.hintColor),
                    controller: CountryControllor,
                    readOnly: true,
                    decoration: InputDecoration(
                      fillColor:
                          Colors.white, // Ensure the fillColor is set to white
                      filled: true, // Set the filled property to true
                      hintText: 'UAE',
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
                    onTap: () {}),
                const SizedBox(
                  height: 20,
                ),
                ReusableCountryPickerFormField(
                  controller: Nationalitycontroller,
                  hintText: 'Nationality',
                  onSelect: (Country country) {
                    setState(() {
                      String countryName = country.name;
                      Nationalitycontroller.text = countryName;
                    });
                    print('Selected country: ${country.name}');
                  },
                ),
                const SizedBox(height: 20),
                CustomSearchField(
                  focusNode: expertiesNode,
               onSubmitted: (String value) {
                 FocusScope.of(context).requestFocus(passwordFocusNode);
  },
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
                  controller: Searchcontrollor,
                ),
                const SizedBox(height: 20),
                ReusableTextForm(
                  focusNode: passwordFocusNode,
                  onSubmitted:   (_) {
                      FocusScope.of(context).requestFocus(confirmPasswordFocusNode);
                    },
                  textCapitalization: TextCapitalization.none,
                  controller: passwordController,
                  hintText: "Password",
                  obscureText: !_passwordVisible,
                  suffixIcon: IconButton(
                    // Toggle icon based on password visibility
                    icon: Icon(
                      _passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: AppColor.btnColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return "Password Should Not Be Empty";
                    } else {
                      return null;
                    }
                  },
                  prefixIcon: const Icon(
                    Icons.password_outlined,
                    color: AppColor.hintColor,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                ReusableTextForm(
                  focusNode: confirmPasswordFocusNode,
                  textCapitalization: TextCapitalization.none,
                  controller: confirmpassController,
                  hintText: " Confirm Password",
                  obscureText: !passwordVisible,
                  suffixIcon: IconButton(
                    // Toggle icon based on password visibility
                    icon: Icon(
                      passwordVisible ? Icons.visibility : Icons.visibility_off,
                      color: AppColor.btnColor,
                    ),
                    onPressed: () {
                      setState(() {
                        passwordVisible = !passwordVisible;
                      });
                    },
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return "Confirm Password Should Not Be Empty";
                    } else if (v != passwordController.text) {
                      return "Passwords do not match";
                    } else {
                      return null;
                    }
                  },
                  prefixIcon: const Icon(
                    Icons.password_outlined,
                    color: AppColor.hintColor,
                  ),
                ),
                const SizedBox(height: 30),
                isLoading
                    ? const CircularProgressIndicator(
                        color: AppColor.blackColor)
                    : ReusableButton(
                        title: "Register",
                        onTap: () async {
                          if (_formKey.currentState!.validate()) {
                            await _signupController.registerUser(
                              nameController,
                              phoneController,
                              emailController,
                              passwordController,
                              confirmpassController,
                              locationController,
                              Nationalitycontroller,
                              CountryControllor,
                              Searchcontrollor,
                              selectedPhoneNumber,
                              countryCode,
                              completenumber,
                              _selectedState,
                              _formKey,
                              setLoading,
                              context,
                            );
                          }
                        },
                      ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const ReusableText(
                      title: "Already have an account?",
                      color: AppColor.textColor,
                      weight: FontWeight.normal,
                    ),
                      const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute<void>(
                              builder: (BuildContext context) =>
                                   signin(email2: widget.email,)),
                        );
                      },
                      child: const Center(
                        child: ReusableText(
                          title: "Sign In",
                          color: AppColor.btnColor,
                          weight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
       Container(
 
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,

    children: [
     const Center(
        child:  Text(
          "By tapping Register, you agree to our",
          style: TextStyle(fontSize: 12),
        ),
      ),
      Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
             Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) =>  PrivacyPolicyScreen(),
          ),
        );
              },
              child: const Text(
                "Terms of Use (EULA)",
                style: TextStyle(
                        fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColor.btnColor, // Set text color to blue
                ),
              ),
            ),
            const Text(
              " and ",
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => PrivacyPolicyScreen(),
          ),
        );
              },
              child: const  Text(
             
                "Privacy Policy",
                style: TextStyle(
                  
                      fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColor.btnColor, // Set text color to blue
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  ),
),



                const SizedBox(
                  height: 15,
                ),
              ],
            )),
          ),
        ),
      ),
    );
  }
    FutureOr<String?> validatePhoneNumber(PhoneNumber? value) {
    if (value == null || value.number.isEmpty) {
      return 'Phone number is required';
    }
    // You can add more specific validation logic here if needed
    return null; // Return null if validation succeeds
  }
  Future<void> _launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

}
