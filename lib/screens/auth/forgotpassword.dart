import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tfnd_app/themes/color.dart';
import 'package:tfnd_app/widgets/reusable_button.dart';
import 'package:tfnd_app/widgets/reusable_text.dart';
import 'package:tfnd_app/widgets/reusable_textformfield.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController emailController = TextEditingController();
  bool isLoading = false; // Track loading state

  Future<void> resetPassword() async {
    try {
      setState(() {
        isLoading = true; // Set loading state to true
      });
      String email = emailController.text.trim();
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      // Show a success message
      Fluttertoast.showToast(
        msg: 'Password reset request sent successfully',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.black,
        textColor: Colors.white,
      );
    } catch (error) {
      // Handle errors
      Fluttertoast.showToast(
        msg: 'Error sending password reset request: $error',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.black,
        textColor: Colors.white,
      );
    } finally {
      setState(() {
        isLoading = false; // Set loading state back to false
      });
    }
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgColor,
      appBar: AppBar(
        backgroundColor: AppColor.bgColor,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back_outlined,
            color: AppColor.hintColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Image(
                      image: AssetImage("assets/images/forgotpassword.png")),
                  const SizedBox(
                    height: 50,
                  ),
                  const ReusableText(
                    title: "Password Reset",
                    color: Colors.black,
                    size: 27,
                    weight: FontWeight.bold,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  const ReusableText(
                    textAlign: TextAlign.center,
                    title:
                        "If you need help resetting your password, we can help by sending you a link to reset it.",
                    color: AppColor.textColor,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  ReusableTextForm(
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return "This field is required";
                      } else if (!v.contains("@")) {
                        return "Email badly formatted";
                      } else {
                        return null;
                      }
                    },
                    textCapitalization: TextCapitalization.none,
                    keyboardType: TextInputType.emailAddress,
                    controller: emailController,
                    hintText: "Email",
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: AppColor.hintColor,
                    ), 
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  isLoading
                      ? const CircularProgressIndicator(
                          color: AppColor.blackColor,
                        ) // Show loading indicator
                      : ReusableButton(
                          title: "Send Request",
                          onTap: () async {
                            if (_formKey.currentState!.validate()) {
                              resetPassword();
                            }
                          },
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
