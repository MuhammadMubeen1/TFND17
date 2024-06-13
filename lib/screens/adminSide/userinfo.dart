import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tfnd_app/themes/color.dart';
import 'package:tfnd_app/widgets/reusable_button.dart';
import 'package:tfnd_app/widgets/reusable_text.dart';
import 'package:tfnd_app/widgets/reusable_textformfield.dart';

class Userprofile extends StatefulWidget {
  final String email;
  final String image;
  final String username;
  final String phone;
  final String Nationality;
  final String location;
  final String state;
  final String industeries;
  final String countrrr;
  const Userprofile({
    Key? key,
    required this.email,
    required this.state,
    required this.location,
    required this.Nationality,
    required this.image,
    required this.username,
    required this.phone,
    required this.industeries,
    required this.countrrr,
  }) : super(key: key);

  @override
  State<Userprofile> createState() => _UserProfileState();
}

class _UserProfileState extends State<Userprofile> {
  bool isRestricted = false;

  @override
  void initState() {
    super.initState();
    // Fetch initial restriction status from Firestore
    listenToRestrictionStatus();
  }

  void listenToRestrictionStatus() {
    // Set up a listener to listen for changes in the document
    FirebaseFirestore.instance
        .collection('RegisterUsers')
        .where('email', isEqualTo: widget.email.toString())
        .snapshots()
        .listen((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        // Fetch the first document from the query snapshot
        final doc = querySnapshot.docs.first;
        // Fetch the current restriction status
        String currentRestriction = doc['restriction'] ?? 'unrestricted';
        // Update the state based on the current status
        setState(() {
          isRestricted = currentRestriction == 'restricted';
        });
      } else {
        // If no document is found, show a Snackbar indicating "User not found!"
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColor.btnColor,
            content: Text('User not found!', style: TextStyle(color: Colors.black)),
          ),
        );
      }
    }, onError: (error) {
      print('Error listening to restriction status: $error');
      // Show a Snackbar indicating the failure to listen to updates
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
           backgroundColor: AppColor.btnColor,
          content: Text('Failed to listen to restriction status.', style: TextStyle(color: Colors.black)),
        ),
      );
    });
  }

  Future<void> updateUserProfile(bool newRestriction) async {
    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('RegisterUsers')
          .where('email', isEqualTo: widget.email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        await doc.reference.update(
            {'restriction': newRestriction ? 'restricted' : 'unrestricted'});

        setState(() {
          isRestricted = newRestriction;
        });

        final message = newRestriction
            ? 'User restricted successfully'
            : 'User unrestricted successfully';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: AppColor.btnColor,
            content: Text(message,style: TextStyle(color: Colors.black)),
          ),
        );

        print(
            'User profile updated successfully. New restriction: ${newRestriction ? 'restricted' : 'unrestricted'}');

        // Check if the new restriction status is true and sign out the user if necessary
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
                backgroundColor: AppColor.btnColor,
            content: Text('User not found!',style: TextStyle(color: Colors.black)),
          ),
        );
      }
    } catch (error) {
      print('Error updating profile: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColor.btnColor,
          content: Text('Failed to update profile. Please try again.', style: TextStyle(color: Colors.black)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.bgColor,
        centerTitle: true,
        automaticallyImplyLeading: true,
        title: const ReusableText(
          title: "Profile",
          color: AppColor.blackColor,
          size: 20,
          weight: FontWeight.w500,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                CircleAvatar(
                  backgroundImage:
                      (widget.image != null && widget.image.isNotEmpty)
                          ? NetworkImage(widget.image as String)
                              as ImageProvider<Object>?
                          : const AssetImage("assets/images/tfndlog.jpg")
                              as ImageProvider<Object>?,
                  radius: 70,
                ),
                const SizedBox(height: 30),
                ReusableTextForm(
                  readOnly: true,
                  hintText: widget.username ?? 'No Username',
                  prefixIcon: const Icon(
                    Icons.person_outlined,
                    color: AppColor.hintColor,
                  ),
                ),
                const SizedBox(height: 20),
                ReusableTextForm(
                  readOnly: true,
                  hintText: widget.email ?? 'No Email',
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: AppColor.hintColor,
                  ),
                ),
                const SizedBox(height: 20),
                ReusableTextForm(
                  readOnly: true,
                  hintText: widget.phone ?? 'No Phone',
                  prefixIcon: const Icon(
                    Icons.phone_android_outlined,
                    color: AppColor.hintColor,
                  ),
                ),
                const SizedBox(height: 20),

                const SizedBox(height: 10),
                TextField(
                  style: const TextStyle(
                    color: Colors.grey, // Change text color
                    fontSize: 12.0, // Change text size
                  ),
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    // hintText: userData!.Location??"",
                    // hintStyle: TextStyle(color: AppColor.hintColor, fontSize: 20),
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
                  readOnly: true,
                  controller: TextEditingController(
                    text: widget!.location ?? "",
                  ),
                  maxLines: null,
                ),

                //     maxLines:5,
                //   readOnly: true,
                //   hintText: widget.location?? 'No Location',
                //   prefixIcon: const Icon(
                //     Icons.location_on_outlined,
                //     color: AppColor.hintColor,
                //   ),
                // ),
                const SizedBox(height: 20),
                ReusableTextForm(
                  readOnly: true,
                  hintText: widget.state ?? 'No state',
                  prefixIcon: const Icon(
                    Icons.location_city_outlined,
                    color: AppColor.hintColor,
                  ),
                ),
                const SizedBox(height: 20),

                ReusableTextForm(
                  maxLines: 1,
                  readOnly: true,
                  hintText: widget.Nationality ?? 'No Nationality',
                  prefixIcon: const Icon(
                    Icons.flag_outlined,
                    color: AppColor.hintColor,
                  ),
                ),

                const SizedBox(height: 20),
                ReusableTextForm(
                  maxLines: 1,
                  readOnly: true,
                  hintText: widget.countrrr ?? 'No Country',
                  prefixIcon: const Icon(
                    Icons.factory_outlined,
                    color: AppColor.hintColor,
                  ),
                ),

                const SizedBox(height: 20),

                ReusableTextForm(
                  maxLines: 1,
                  readOnly: true,
                  hintText: widget.industeries ?? 'No Country',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(top: 13, left: 12),
                    child: FaIcon(
                      FontAwesomeIcons.globe,
                      color: Colors.grey,
                      size: 20.0,
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                ReusableButton(
                  title: isRestricted ? 'Unrestrict User' : 'Restrict User',
                  onTap: () {
                    updateUserProfile(!isRestricted);
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
