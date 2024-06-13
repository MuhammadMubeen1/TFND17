import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tfnd_app/models/AddBusinessModel.dart';
class BusinessBarController extends ChangeNotifier {
  final String emailUser;
  Stream<List<AddBusinessModel>>? businessStream;

  BusinessBarController(this.emailUser) {
    businessStream = getBusinessStream();
  }

  Stream<List<AddBusinessModel>> getBusinessStream() {
    return FirebaseFirestore.instance
        .collection("BusinessRegister")
        .doc(emailUser)
        .collection("Businesses")
        .orderBy(FieldPath.documentId, descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return AddBusinessModel.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Future<void> updateClickCount(String businessId) async {
    try {
      final businessRef = FirebaseFirestore.instance
          .collection("BusinessRegister")
          .doc(businessId);
      final doc = await businessRef.get();

      if (doc.exists) {
        final currentClickCount =
            int.tryParse(doc.data()?['clickCount'] ?? '0') ?? 0;

        await businessRef.update({'clickCount': currentClickCount + 1});
        print('Click count updated successfully.');
      } else {
        print('Business document with ID $businessId does not exist.');
      }
    } catch (e) {
      print('Error updating click count: $e');
    }
  }
}
