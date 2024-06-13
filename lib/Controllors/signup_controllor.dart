import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:tfnd_app/themes/color.dart';
import 'package:tfnd_app/widgets/const.dart';
import 'package:tfnd_app/models/AddUserModel.dart';
import 'package:tfnd_app/screens/auth/otpverfied.dart';
import 'package:email_otp/email_otp.dart';


class SignupController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  EmailOTP myauth = EmailOTP();

  Future<void> registerUser(
    TextEditingController nameController,
   TextEditingController phoneController,
    TextEditingController emailController,
    TextEditingController passwordController,
    TextEditingController confirmpassController,
    TextEditingController locationController,
    TextEditingController nationalityController,
    TextEditingController countryController,
    TextEditingController searchController,
    String? selectedPhoneNumber,
    String? phonecode, 
    String? completenumber,
    String? selectedState,
    GlobalKey<FormState> formKey,
    Function(bool) setLoading,
    BuildContext context,
  ) async {
    if (formKey.currentState!.validate()) {
      setLoading(true);

      try {
        if (passwordController.text != confirmpassController.text) {
          Fluttertoast.showToast(
          backgroundColor: AppColor.btnColor,
            msg: 'Passwords do not match',
            textColor: Colors.black,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
          );
          setLoading(false);
          return;
        }
  
        UserCredential user =
            await _auth.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        int id = DateTime.now().millisecondsSinceEpoch;

        String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
        String currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
        String imageUrl =
            'https://img1.wsimg.com/isteam/ip/ac71e8fd-9a69-4b93-a845-896c49c38929/image_6483441.JPG/:/rs=w:2320,h:2320';

        AddUserModel dataModel = AddUserModel(
          counter: '0',
          name: nameController.text,
          completenumber:completenumber,
          email: emailController.text,
          password: passwordController.text,
          subscription: "unpaid",
          phoneNumber: selectedPhoneNumber,
          restriction: "unrestricted",
          verification: "unverified",
          uid: id,
          phonecode: phonecode,
          image: imageUrl,
          Location: locationController.text,
          Nationality: nationalityController.text,
          State: selectedState,
          date: currentDate,
          time: currentTime,
          firstDate: '',
          nextDueDate: '',
          industeries: searchController.text,
          Countryyy: 'UAE',
        );

        await FirebaseFirestore.instance
            .collection(StaticInfo.registerUser)
            .doc('$id')
            .set(dataModel.toJson());

        setLoading(false);

        Fluttertoast.showToast(
          backgroundColor: AppColor.btnColor,
          msg:'Email verification link sent. Please verify your email before signing in.',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          textColor: Colors.black
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => EmailVerificationScreen(),
          ),
        );
      } catch (e) {
        if (e is FirebaseAuthException) {
          if (e.code == 'email-already-in-use') {
            Fluttertoast.showToast(
              backgroundColor: AppColor.btnColor,
                msg: 'Email is already in use',
                textColor: Colors.black,
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.TOP);
          } else {
            Fluttertoast.showToast(msg: 'Error: ${e.message}');
          }
        } else {
          Fluttertoast.showToast(
            backgroundColor: AppColor.btnColor,
              msg: 'Some Error Occurred',
      textColor: Colors.black,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP);
        }
print(e.toString());
        setLoading(false);
      }
    }
  }

  FutureOr<String?> validatePhoneNumber(PhoneNumber? value) {
    if (value == null || value.number.isEmpty) {
      return 'Phone number is required';
    }
    return null;
  }
}


final List<String> suggestions = [
   "Aerospace & Defense",
  "Arts & Design",
  "Banking",
  "Chemicals",
  "Construction",
  "Consumer Goods",
  "Education",
  "Energy",
  "Engineering",
  "Entertainment",
  "Finance",
  "Food & Beverages",
  "Government Administration",
  "Healthcare",
  "Hospitality",
  "Human Resources",
  "Insurance",
  "Internet",
  "Investment Banking",
  "Investment Management",
  "Journalism",
  "Legal",
  "Manufacturing",
  "Marketing & Advertising",
  "Media Production",
  "Medical Devices",
  "Mental Health Care",
  "Military & Defense",
  "Mining",
  "Music",
  "Non-profit",
  "Oil & Energy",
  "Pharmaceuticals",
  "Public Policy",
  "Real Estate",
  "Recruiting",
  "Renewable Energy",
  "Research",
  "Retail",
  "Software Development",
  "Sports",
  "Telecommunications",
  "Translation & Interpretation",
  "Transportation",
  "Venture Capital"
];
