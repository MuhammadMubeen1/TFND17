import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tfnd_app/screens/adminSide/buttom_navigation.dart';
import 'package:tfnd_app/screens/auth/signup.dart';
import 'package:tfnd_app/screens/userSide/bottomnavbar.dart';
import 'package:tfnd_app/themes/color.dart';
import 'package:tfnd_app/widgets/const.dart';

class SignInController {
  late BuildContext context;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _passwordVisible = false;
  bool isLoading = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  SignInController(this.context);

  Future<void> userLogin() async {
    setState(() {
      isLoading = true;
    });

    SharedPreferences preferences = await SharedPreferences.getInstance();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    try {
      // Check if the user is an admin
      bool isAdmin = await checkAdmin(email, password);
      if (isAdmin) {
        // Proceed with admin login
        await preferences.setBool('isLoggedIn', true);
        await preferences.setString('email', email);

        setState(() {
          isLoading = false;
        });

        Fluttertoast.showToast(
          msg: 'Successfully Logged In as Admin',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          backgroundColor: AppColor.btnColor,
          textColor: Colors.black,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Buttomnavigation (adminemail: email,)), // Replace with your admin bottom navigation screen
          
        );
        return;
      }

      // Sign in with Firebase Authentication for regular users
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if the user exists in Firestore
      var userSnapshot = await FirebaseFirestore.instance
          .collection(StaticInfo.registerUser)
          .where('email', isEqualTo: email)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        // User exists in Firestore, proceed with login
        var userData = userSnapshot.docs[0].data();

        // Check if the user is restricted
        if (userData['restriction'] == 'restricted') {
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(
            msg: 'This user has been restricted by Admin. Please contact admin@thefemalenetworkdubai.com',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            backgroundColor: AppColor.btnColor,
            textColor: Colors.black,
          );
          return;
        }

        // Check if the email is verified
        if (userData['verification'] != 'verified') {
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(
            msg: 'Email is not verified. Please verify your email first.',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            backgroundColor: AppColor.btnColor,
            textColor: Colors.black,
          );
          return;
        }

        // Proceed with logging in the user
        await preferences.setBool('isLoggedIn', true);
        await preferences.setString('email', email);

        setState(() {
          isLoading = false;
        });

        Fluttertoast.showToast(
          msg: 'Successfully Logged In',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          backgroundColor: AppColor.btnColor,
          textColor: Colors.black,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BottomNavBar(userEmail: email, status: ''),
          ),
        );
      } else {
        // User does not exist in Firestore
        setState(() {
          isLoading = false;
        });

        Fluttertoast.showToast(
          msg: 'Your account has been deleted',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          backgroundColor: AppColor.btnColor,
          textColor: Colors.black,
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(
        msg: 'Incorrect username or password',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        backgroundColor: AppColor.btnColor,
        textColor: Colors.black,
      );
      print("Error signing in: $e");
    }
  }

  Future<bool> checkAdmin(String email, String password) async {
    try {
      var adminAuthResult = await FirebaseFirestore.instance
          .collection("Admin")
          .where('email', isEqualTo: email)
          .where('password', isEqualTo: password)
          .get();

      return adminAuthResult.docs.isNotEmpty;
    } catch (e) {
      print("Error checking admin status: $e");
      return false; // Handle errors gracefully, return false by default
    }
  }

  Future<bool> checkUserRestriction(String email) async {
    try {
      var userAuthResult = await FirebaseFirestore.instance
          .collection(StaticInfo.registerUser)
          .where('email', isEqualTo: email)
          .get();
      var userData = userAuthResult.docs[0].data();
      return userData['restriction'] == 'restricted';
    } catch (e) {
      print("Error checking user restriction: $e");
      return false;
    }
  }

  Future<bool> checkEmailVerification(String email) async {
    try {
      var userAuthResult = await FirebaseFirestore.instance
          .collection(StaticInfo.registerUser)
          .where('email', isEqualTo: email)
          .get();
      var userData = userAuthResult.docs[0].data();
      return userData['verification'] == 'verified';
    } catch (e) {
      print("Error checking email verification: $e");
      return false;
    }
  }

  void setState(VoidCallback fn) {
    if (context is StatefulElement) {
      StatefulElement statefulElement = context as StatefulElement;
      if (statefulElement.state.mounted) {
        statefulElement.state.setState(fn);
      }
    }
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }
}
