import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:tfnd_app/screens/adminSide/buttom_navigation.dart';
import 'package:tfnd_app/screens/auth/signin.dart';
import 'package:tfnd_app/screens/userSide/bottomnavbar.dart';
import 'package:tfnd_app/themes/color.dart';


class SplashBody extends StatefulWidget {
  String? email3;
    SplashBody({
    Key? key,
    required this.email3
  }) : super(key: key);

  @override
  _SplashBodyState createState() => _SplashBodyState();
}

class _SplashBodyState extends State<SplashBody> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    navigate();
  }

  void navigate() async {
    await Future.delayed(Duration(seconds: 1));

    final isLoggedIn = await checkLoginStatus();
    if (isLoggedIn) {
      final currentEmail = await getEmailFromSharedPreferences();
      if (currentEmail == null || currentEmail.isEmpty) {
        // Handle null or empty email scenario by navigating to signin screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => signin(email2: '',)),
        );
      } else {
        final isAdmin = await checkAdminStatus(currentEmail);
        if (isAdmin) {
          // Navigate to admin dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Buttomnavigation(adminemail: currentEmail),
            ),
          );
        } else {
          // Navigate to user dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => BottomNavBar(userEmail: currentEmail, status: ''),
            ),
          );
        }
      }
    } else {
      // Navigate to signin screen if not logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => signin(email2:widget.email3.toString() )),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<bool> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    return isLoggedIn;
  }

  Future<String?> getEmailFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }

  Future<bool> checkAdminStatus(String? email) async {
    if (email == null) return false;
    QuerySnapshot adminResult = await FirebaseFirestore.instance
        .collection("Admin")
        .where(
          'email',
          isEqualTo: email.toLowerCase(),
        )
        .get();
    return adminResult.docs.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/splashscreen.jpeg"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 500, left: 0),
            child: _isLoading
                ? const CircularProgressIndicator(
                    color:  Colors.black,
                  )
                : SizedBox(),
          ),
        ),
      ],
    );
  }
}
