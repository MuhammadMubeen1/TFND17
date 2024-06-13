// controllers/scanner_controller.dart

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:tfnd_app/models/AddUserModel.dart';
import 'package:tfnd_app/screens/subscription.dart';


import 'package:tfnd_app/themes/color.dart';

class ScannerController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SubscriptionService _subscriptionService = SubscriptionService();

 

  Future<void> checkAndUpdateSubscriptionStatus() async {
    try {
      DateTime currentTimestamp = DateTime.now();

      QuerySnapshot querySnapshot = await _firestore
          .collection('RegisterUsers')
          .where('nextDueDate', isLessThanOrEqualTo: currentTimestamp)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        for (DocumentSnapshot documentSnapshot in querySnapshot.docs) {
          await documentSnapshot.reference.update({
            'subscription': 'unpaid',
          });
        }
        print('All expired subscriptions updated successfully');
      } else {
        print('No subscriptions found for update');
      }
    } catch (error) {
      print('Error updating subscriptions: $error');
    }
  }

  Future<void> listenToUserData(String currentUserEmail, Function(AddUserModel?) onDataReceived) async {
    try {
      FirebaseFirestore.instance
          .collection('RegisterUsers')
          .where('email', isEqualTo: currentUserEmail)
          .snapshots()
          .listen((QuerySnapshot userSnapshot) {
        if (userSnapshot.docs.isNotEmpty) {
          AddUserModel userData = AddUserModel.fromJson(
              userSnapshot.docs.first.data() as Map<String, dynamic>);
          onDataReceived(userData);
        } else {
          onDataReceived(null);
        }
      });
    } catch (e) {
      print("Error listening to user data: $e");
    }
  }

  Future<void> saveBusinessDetailsToFirestore(
      String businessName, String discount, AddUserModel userData, String businessId) async {
    try {
      CollectionReference businessDetailsRef =
          FirebaseFirestore.instance.collection('ScannedBusinessDetails');
      DateTime currentTime = DateTime.now();
      String formattedDate = DateFormat('yyyy-MM-dd').format(currentTime);

      await businessDetailsRef.add({
        'businessName': businessName,
        'discount': discount,
        'timestamp': formattedDate,
        'name': userData.name,
        'email': userData.email,
        'businessid': businessId,
      });
      print('Business details saved to Firestore: $businessName, $discount');
    } catch (error) {
      print('Error saving business details to Firestore: $error');
    }
  }

  Future<bool> canScanQR(String businessId, String userEmail) async {
    try {
      DateTime now = DateTime.now();
      int currentMonth = now.month;
      int currentYear = now.year;

      String collectionPath = 'scan_records';

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(collectionPath)
          .where('businessId', isEqualTo: businessId)
          .where('userEmail', isEqualTo: userEmail)
          .where('year', isEqualTo: currentYear)
          .where('month', isEqualTo: currentMonth)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot scanRecord = querySnapshot.docs.first;
        int scanCount = scanRecord['scanCount'];

        return scanCount < 3;
      } else {
        return true;
      }
    } catch (e) {
      print('Error checking scan limit: $e');
      return false;
    }
  }

  Future<void> recordScan(String businessId, String userEmail) async {
    try {
      DateTime now = DateTime.now();
      int currentMonth = now.month;
      int currentYear = now.year;

      String collectionPath = 'scan_records';

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(collectionPath)
          .where('businessId', isEqualTo: businessId)
          .where('userEmail', isEqualTo: userEmail)
          .where('year', isEqualTo: currentYear)
          .where('month', isEqualTo: currentMonth)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot scanRecord = querySnapshot.docs.first;
        await scanRecord.reference.update({
          'scanCount': FieldValue.increment(1),
        });
        print('Scan count incremented.');
      } else {
        await FirebaseFirestore.instance.collection(collectionPath).add({
          'businessId': businessId,
          'userEmail': userEmail,
          'scanDate': now,
          'year': currentYear,
          'month': currentMonth,
          'scanCount': 1,
        });
        print('New scan record created.');
      }
    } catch (e) {
      print('Error recording scan: $e');
    }
  }

  Future<void> showDialogForScannedQR(BuildContext context, Barcode scanData, Function() onDialogClosed) async {
    try {
      List<String> qrParts = scanData.code!.split('|');
      String businessName = qrParts[2];

       AwesomeDialog(
       
        btnOkColor: AppColor.btnColor,
        buttonsTextStyle: TextStyle(color: Colors.black),
        context: context,
        animType: AnimType.scale,
        dialogType: DialogType.info,
     
        
        body: Column(
          children: [
            Text(" $businessName", style: TextStyle(color: AppColor.btnColor, fontWeight: FontWeight.w400),),
          ],
        ),
        btnOkOnPress: () {

            
        },
      ).show();
    } catch (e) {
      print('Error showing dialog: $e');
    }
  }
}
