

import 'package:flutter/material.dart';
import 'package:tfnd_app/Controllors/profilr_controllor.dart';
import 'package:tfnd_app/models/AddUserModel.dart';
import 'package:tfnd_app/screens/auth/signin.dart';
import 'package:tfnd_app/screens/businessSide/bBottomnavbar.dart';
import 'package:tfnd_app/screens/userSide/business_request/user_request.dart';
import 'package:tfnd_app/screens/userSide/editProfile.dart';
import 'package:tfnd_app/themes/color.dart';
import 'package:tfnd_app/widgets/reusable_outlined_button.dart';
import 'package:tfnd_app/widgets/reusable_text.dart';
import 'package:tfnd_app/widgets/reusable_textformfield.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tfnd_app/widgets/status_update.dart';

class profileBar extends StatefulWidget {
  final String currentUserEmail;

  const profileBar({
    Key? key,
    required this.currentUserEmail,
  }) : super(key: key);

  @override
  State<profileBar> createState() => _ProfileBarState();
}

class _ProfileBarState extends State<profileBar> {
  final ProfileController _controller = ProfileController();
  AddUserModel? userData;
  String? status;

  @override
  void initState() {

    super.initState();
    _controller.getUserDataStream(widget.currentUserEmail).listen((user) {
      setState(() {
        userData = user;
      });
    });
    _controller.listenToRequestStatus(widget.currentUserEmail, (newStatus) {
      setState(() {
        status = newStatus;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => Editprofile(
                    comlete: userData?.completenumber ?? '',
                    image: userData?.image ?? '',
                    phonenumber: userData?.phoneNumber ?? '',
                    password: userData?.password ?? '',
                    name: userData?.name ?? '',
                    eamil: userData?.email ?? '',
                    state: userData?.State ?? '',
                    nationality: userData?.Nationality ?? '',
                    location: userData?.Location ?? '',
                    Conterrr: userData?.Countryyy ?? '',
                    Industreis: userData?.industeries ?? '',
                    phonecode: userData?.phonecode ?? "",
                  ),
                ),
              );
            },
            child: const ImageIcon(
              AssetImage("assets/icons/edit3.png"),
              size: 23,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Refresh the user data and request status
            setState(() {
              _controller.listenToRequestStatus(widget.currentUserEmail, (newStatus) {
                setState(() {
                  status = newStatus;
                });
              });
            });
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: userData != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10),
                        CircleAvatar(
                          backgroundImage: (userData!.image != null && userData!.image!.isNotEmpty)
                              ? NetworkImage(userData!.image!) as ImageProvider<Object>?
                              : const AssetImage("assets/images/tfndlog.jpg"),
                          radius: 70,
                        ),
                        const SizedBox(height: 10),
                        ReusableOutlinedButton(
                          buttonColor: AppColor.blackColor,
                          title: _getButtonTitle(),
                          onTap: () {
                            _handleButtonTap(context);
                          },
                        ),
                        const SizedBox(height: 12),
                        ReusableOutlinedButton(
                          buttonColor: AppColor.blackColor,
                          title: "Log Out",
                          onTap: () async {
                            try {
                              await logout(context);
                            } catch (e) {
                              print("Error signing out: $e");
                            }
                          },
                        ),
                        const SizedBox(height: 10),
                        ReusableOutlinedButton(
                          buttonColor: AppColor.blackColor,
                          title: "Delete Account",
                          onTap: () async {
                            _confirmDeleteAccount(context);
                          },
                        ),
                        const SizedBox(height: 10),
                        ReusableTextForm(
                          readOnly: true,
                          hintText: userData!.name ?? "null",
                          prefixIcon: const Icon(
                            Icons.person_outlined,
                            color: AppColor.hintColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ReusableTextForm(
                          readOnly: true,
                          hintText: userData!.completenumber ?? 'null',
                          prefixIcon: const Icon(
                            Icons.phone_outlined,
                            color: AppColor.hintColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ReusableTextForm(
                          readOnly: true,
                          hintText: userData!.email ?? 'null',
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            color: AppColor.hintColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            prefixIcon: const Icon(
                              Icons.location_on_outlined,
                              color: AppColor.hintColor,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.white, width: 2.0),
                              borderRadius: BorderRadius.circular(18.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.white, width: 1.0),
                              borderRadius: BorderRadius.circular(18.0),
                            ),
                          ),
                          readOnly: true,
                          controller: TextEditingController(
                            text: userData?.Location ?? "",
                          ),
                          maxLines: null,
                        ),
                        const SizedBox(height: 10),
                        ReusableTextForm(
                          readOnly: true,
                          hintText: userData!.State ?? "null",
                          prefixIcon: const Icon(
                            Icons.location_city_outlined,
                            color: AppColor.hintColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ReusableTextForm(
                          readOnly: true,
                          hintText: userData!.Countryyy ?? "null",
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(top: 13, left: 12),
                            child: FaIcon(
                              FontAwesomeIcons.globe,
                              color: Colors.grey,
                              size: 20.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ReusableTextForm(
                          readOnly: true,
                          hintText: userData!.Nationality ?? 'null',
                          prefixIcon: const Icon(
                            Icons.flag_outlined,
                            color: AppColor.hintColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ReusableTextForm(
                          readOnly: true,
                          hintText: userData!.industeries ?? "null",
                          prefixIcon: const Icon(
                            Icons.factory_outlined,
                            color: AppColor.hintColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    )
                  : const Center(
                      child: CircularProgressIndicator(
                        color: AppColor.blackColor,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  String _getButtonTitle() {
    if (status == null) {
      return "Request to add business";
    } else if (status == "pending") {
      return "My Business";
    } else if (status == "approved") {
      return "My Business";
    } else {
      return "My Business";
    }
  }

  void _handleButtonTap(BuildContext context) {
    if (status == null) {
      _showPending();
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => Requestform(
            emails: widget.currentUserEmail,
          ),
        ),
      );
    } else if (status == "pending") {
      _showPendingSnackbar();
    } else if (status == "rejected") {
      _showrejectSnackbar();
    } else if (status == "approved") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => Bottomnavbar(
            currentuser: widget.currentUserEmail,
            userData: userData,
          ),
        ),
      );
    }
  }

  void _showPendingSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColor.btnColor,
        content: Text(
          'Your Business Request is pending!',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showrejectSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColor.btnColor,
        content: Text(
          'Your business request has been rejected. Please contact admin@thefemalenetworkdubai.com',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => signin(email2: widget.currentUserEmail),
      ),
    );
  }
Future<void> deleteAccount() async {
  try {
    // Find the user document by email
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('RegisterUsers')
        .where('email', isEqualTo: widget.currentUserEmail)
        .get();

    print('Query Snapshot: $querySnapshot'); // Add this print statement

    // Check if the document exists
    if (querySnapshot.size > 0) {
      // Get the document ID (should be only one document)
      String docId = querySnapshot.docs[0].id;
      print('Doc ID: $docId'); // Add this print statement
 _Account_confirmation();
      // Delete the document
      await FirebaseFirestore.instance.collection('RegisterUsers').doc(docId).delete();
 Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => signin(email2: widget.currentUserEmail),
      ),
    );
      // Delete the Firebase Authentication user
    } else {
      print('No document found with email: ${widget.currentUserEmail}');
    }
  } catch (e) {
    print("Error deleting account: $e");
    rethrow; // Rethrow the error to stop the function execution
  }
}

  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Delete Account"),
          content: const Text("Are you sure you want to delete your account? This action is permanent and cannot be undone."),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel",style: TextStyle(color: AppColor.btnColor, fontWeight: FontWeight.bold),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Delete", style: TextStyle(color: AppColor.btnColor, fontWeight: FontWeight.bold),),
              onPressed: () async {
                Navigator.of(context).pop();
                await deleteAccount();
         
              },
            ),
          ],
        );
      },
    );
  }

  void _showPending() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColor.btnColor,
        content: Text(
          'Send request to admin for business!',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }


  void _Account_confirmation() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColor.btnColor,
        content: Text(
          'Your account deleted sucessfully',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }
}
