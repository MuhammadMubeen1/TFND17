import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tfnd_app/models/AddEventModel.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<AddEventModel>> fetchEvents() async {
    List<AddEventModel> events = [];

    try {
      QuerySnapshot snapshot = await _firestore
          .collection("adminevents")
          .orderBy(FieldPath.documentId, descending: true)
          .get();

      for (var doc in snapshot.docs) {
        AddEventModel dataModel = AddEventModel.fromJson(doc.data() as Map<String, dynamic>);
        events.add(dataModel);
      }
    } catch (e) {
      print("Error fetching events: $e");
      throw e;
    }

    return events;
  }
}
