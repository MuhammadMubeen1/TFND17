// controllers/profile_controller.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tfnd_app/models/AddUserModel.dart';

class ProfileController {
  StreamSubscription<QuerySnapshot>? _requestStatusSubscription;

  Stream<AddUserModel?> getUserDataStream(String currentUserEmail) {
    try {
      return FirebaseFirestore.instance
          .collection('RegisterUsers')
          .where('email', isEqualTo: currentUserEmail)
          .snapshots()
          .map((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          return AddUserModel.fromJson(
             snapshot.docs.first.data() as Map<String, dynamic>);
        } else {
          return null;
        }
      });
    } catch (e) {
      print("Error fetching user data: $e");
      return const Stream.empty();
    }
  }


  Future<void> listenToRequestStatus(
      String currentUserEmail, Function(String?) onData) async {
    try {
      _requestStatusSubscription = FirebaseFirestore.instance
          .collection('requests')
          .where('curentemail', isEqualTo: currentUserEmail)
          .snapshots()
          .listen((QuerySnapshot requestSnapshot) {
        if (requestSnapshot.docs.isNotEmpty) {
          String newStatus = requestSnapshot.docs.first['status'];
          onData(newStatus);
        } else {
          onData(null);
        }
      });
    } catch (e) {
      print('Error listening to request status: $e');
    }
  }

  void dispose() {
    _requestStatusSubscription?.cancel();
  }
}
