import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tfnd_app/models/AddBusinessModel.dart';
import 'package:tfnd_app/models/AddEventModel.dart';
import 'package:tfnd_app/models/AddUserModel.dart';
import 'package:tfnd_app/screens/auth/signin.dart';
import 'package:tfnd_app/themes/color.dart';

class HomeController {
  final String currentUserEmail;
  bool _initialDataLoaded = false;
  final _businessController = StreamController<List<AddBusinessModel>>();
  final _eventController = StreamController<List<AddEventModel>>();
  final _userController = StreamController<AddUserModel?>();

  HomeController(this.currentUserEmail);

  Stream<List<AddBusinessModel>> getBusinessesOnce() {
    if (!_initialDataLoaded) {
      FirebaseFirestore.instance
          .collection("BusinessRegister")
          .orderBy(FieldPath.documentId, descending: true)
          .get()
          .then((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          _businessController.add(snapshot.docs
              .map((doc) => AddBusinessModel.fromJson(doc.data() as Map<String, dynamic>))
              .toList());
        }
      }).catchError((error) {
        print('Error fetching businesses: $error');
        // Handle error as needed
      });
      _initialDataLoaded = true; // Set flag after initial load
    }
    return _businessController.stream;
  }

  Stream<List<AddBusinessModel>> getMostClickableBusinesses() {
    return FirebaseFirestore.instance
        .collection("BusinessRegister")
        .orderBy('clickCount', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AddBusinessModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Stream<List<AddEventModel>> getEvents() {
    return FirebaseFirestore.instance
        .collection("adminevents")
        .orderBy(FieldPath.documentId, descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AddEventModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Stream<AddUserModel?> getUserDataStream() {
    return FirebaseFirestore.instance
        .collection('RegisterUsers')
        .where('email', isEqualTo: currentUserEmail)
        .snapshots()
        .map((snapshot) => snapshot.docs.isNotEmpty
            ? AddUserModel.fromJson(snapshot.docs.first.data() as Map<String, dynamic>)
            : null);
  }

  Future<void> checkUserRestrictionStatus(BuildContext context) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('RegisterUsers')
          .doc(currentUserEmail)
          .get();

      if (snapshot.exists) {
        final isRestricted = snapshot.get('restriction');
        print('User restriction status: $isRestricted');

        if (isRestricted == "restricted") {
          print('User is restricted. Signing out...');
          await FirebaseAuth.instance.signOut();
          print('User signed out successfully.');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => signin(email2:currentUserEmail,)),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColor.btnColor,
              content: Text('You Are Restricted. Please Contact Admin', style: TextStyle(color: Colors.black),),
              duration: Duration(seconds: 6),
            ),
          );
        }
      }
    } catch (e) {
      print('Error checking user restriction status: $e');
    }
  }

  Future<String?> getCurrentUserImage() async {
    try {
      var userSnapshot = await FirebaseFirestore.instance
          .collection("RegisterUsers")
          .doc(currentUserEmail)
          .get();

      if (userSnapshot.exists) {
        return userSnapshot.get("image") as String?;
      }
    } catch (e) {
      print("Error fetching current user's image: $e");
    }
    return null;
  }

  Future<void> updateClickCount(String businessId) async {
    try {
      final businessRef = FirebaseFirestore.instance
          .collection("BusinessRegister")
          .doc(businessId);
      final doc = await businessRef.get();

      if (doc.exists) {
        final currentClickCount = doc.get('clickCount') ?? 0;
        await businessRef.update({'clickCount': currentClickCount + 1});
        print('Click count updated successfully.');
      } else {
        print('Business document with ID $businessId does not exist.');
      }
    } catch (e) {
      print('Error updating click count: $e');
    }
  }

  void dispose() {
    _businessController.close();
    _eventController.close();
    _userController.close();
  }
}
