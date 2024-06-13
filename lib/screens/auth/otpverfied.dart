import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tfnd_app/screens/auth/signin.dart';
import 'package:tfnd_app/themes/color.dart';
import 'package:tfnd_app/widgets/reusable_button.dart';

class EmailVerificationScreen extends StatefulWidget {
  EmailVerificationScreen({Key? key}) : super(key: key);

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool isEmailVerified = false;
  Timer? timer;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isSendingVerificationEmail = false;

  @override
  void initState() {
    super.initState();
    // Start the timer to check email verification status periodically
    timer = Timer.periodic (Duration(seconds: 2), (timer) {
      checkEmailVerified();
       
    });

  FirebaseAuth.instance.currentUser?.sendEmailVerification();
                    Fluttertoast.showToast(
                      backgroundColor: AppColor.btnColor,
                      msg: 'Verification email sent. Please wait...',
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.TOP,
                      textColor: Colors.black,
                    );

  }

  void checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser?.reload();

    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (isEmailVerified) {
      // Update Firestore document if email is verified
      FirebaseFirestore.instance
          .collection('RegisterUsers')  
          .where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email)
          .get()
          .then((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          final doc = querySnapshot.docs.first;
          doc.reference.update({'verification': 'verified'}).then((_) {
            Fluttertoast.showToast(
              backgroundColor: AppColor.btnColor,
              msg: 'Email Successfully Verified.',
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              textColor: Colors.black,
            );

            // Navigate to the signin screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute<void>(
                builder: (BuildContext context) => signin(email2: '',),
              ),
            );

            // Cancel the timer
            timer?.cancel();
          }).catchError((error) {
            print('Failed to update verification status: $error');
          });
        }
      });
    }
  }

  @override
  void dispose() {
// TODO: implement dispose
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 35),
              const SizedBox(height: 30),
              Container(
                height: 200,
                width: 200,
                child: const Image(image: AssetImage("assets/images/tfndd.png")),
              ),
            const  SizedBox(
                height: 20,
              ),
             
                 const  SizedBox(
                height: 20,
              ),
              const Center(
                child: Text(
                  'Check your Email',
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Center(
                  child: Text(
                    'TFND has sent you an Email on ${_auth.currentUser?.email}',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator(color: Colors.black,)),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.0),
                child: Center(
                  child: Text(
                    'Your email is pending verfication...',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 57),
            Container(width: 250,
              child: ElevatedButton(
                
                onPressed: () async {
                  setState(() {
                    isSendingVerificationEmail = true;
                  });
                  try {
                    await FirebaseAuth.instance.currentUser?.sendEmailVerification();
                    Fluttertoast.showToast(
                      backgroundColor: AppColor.btnColor,
                      msg: 'Verification email sent. Please wait...',
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.TOP,
                      textColor: AppColor.blackColor,
                    );
                  } catch (e) {
                    debugPrint('$e');
                  }
                  setState(() {
                    isSendingVerificationEmail = false;
                  });
                },
               style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.btnColor,
              textStyle: const TextStyle(fontSize: 18),
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),),
                child: isSendingVerificationEmail
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      )
                    : const Text(
                        "Resend",
                        style: TextStyle(fontSize: 15.0, color: Colors.black, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
         ],
          ),
        ),
      ),
    );
  }
}
