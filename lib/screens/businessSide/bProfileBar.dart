import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tfnd_app/models/AddUserModel.dart';
import 'package:tfnd_app/screens/auth/signin.dart';
import 'package:tfnd_app/screens/userSide/bottomnavbar.dart';
import 'package:tfnd_app/themes/color.dart';
import 'package:tfnd_app/widgets/reusable_outlined_button.dart';
import 'package:tfnd_app/widgets/reusable_text.dart';
import 'package:tfnd_app/widgets/reusable_textformfield.dart';

class ProfileBar extends StatefulWidget {
  String currentuser;
  final AddUserModel? userdat;

  ProfileBar({super.key, required this.currentuser, required this.userdat});

  @override
  State<ProfileBar> createState() => _bProfileBarState();
}

class _bProfileBarState extends State<ProfileBar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.bgColor,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const ReusableText(
          title: "Profile",
          color: AppColor.blackColor,
          size: 20,
          weight: FontWeight.w500,
        ),
        actions: [],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 15,
                ),
                CircleAvatar(
                  backgroundImage: (widget.userdat!.image != null &&
                          widget.userdat!.image!.isNotEmpty)
                      ? NetworkImage(widget.userdat!.image! as String)
                          as ImageProvider<Object>?
                      : const AssetImage("assets/images/tfndlog.jpg"),
                  radius: 70,
                ),
                const SizedBox(
                  height: 30,
                ),
                ReusableTextForm(
                  hintText: '${widget.userdat!.name ?? 'N/A'}',

                  // prefixIcon: Image(image: AssetImage("assets/icons/email.png")),
                  prefixIcon: const Icon(
                    Icons.person_outlined,
                    color: AppColor.hintColor,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ReusableTextForm(
                  hintText: "${widget.userdat!.phoneNumber ?? 'N/A'}",
                  // prefixIcon: Image(image: AssetImage("assets/icons/email.png")),
                  prefixIcon: const Icon(
                    Icons.phone_outlined,
                    color: AppColor.hintColor,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ReusableTextForm(
                  hintText: "${widget.userdat!.email ?? 'N/A'}",
                  // prefixIcon: Image(image: AssetImage("assets/icons/email.png")),
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: AppColor.hintColor,
                  ), 
                ),
                const SizedBox(
                  height: 20,
                ),
                const SizedBox(
                  height: 20,
                ),
                ReusableOutlinedButton(
                    title: "Switch to User Account",
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute<void>(
                            builder: (BuildContext context) => BottomNavBar(
                                  userEmail: widget.currentuser,
                                  status: '',
                                )),
                      );
                    }),
                const SizedBox(
                  height: 20,
                ),
                ReusableOutlinedButton(
                  title: "Log Out",
                  onTap: () async {
                    try {
                      await FirebaseAuth.instance
                          .signOut(); // Sign out the current user
                      // Navigate to the login or home screen
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) =>
                      signin(email2: '',), // Replace LoginScreen with your login screen widget
                        ),
                      );
                    } catch (e) {
                      print("Error signing out: $e");
                      // Handle sign out errors
                    }
                  },
                ),
             const SizedBox(
                  height: 30,
                ), 
              ],
            ),
          ),
        ),
      ),
    );
  }
}
