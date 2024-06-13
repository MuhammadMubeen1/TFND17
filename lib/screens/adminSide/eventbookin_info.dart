import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentScreen extends StatefulWidget {
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  TextEditingController? _searchController;
  Stream<QuerySnapshot>? _paymentStream;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _paymentStream =
        FirebaseFirestore.instance.collection('payments').snapshots();
  }

  @override
  void dispose() {
    _searchController?.dispose(); // Use null-aware operator
    super.dispose();
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Event Booking Details'),
    ),
    body: Column( // Wrap the StreamBuilder with a Column
      children: [
        Expanded( // Use Expanded to allow the StreamBuilder to take the remaining space
          child: StreamBuilder<QuerySnapshot>(
            stream: _paymentStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child:
                      CircularProgressIndicator(), // Loading indicator while fetching data
                );
              }

              List<DocumentSnapshot> paymentDocs = snapshot.data!.docs;
              return ListView.builder(
                itemCount: paymentDocs.length,
                itemBuilder: (context, index) {
                  // Access payment data for the current index
                  Map<String, dynamic>? paymentData =
                      paymentDocs[index].data() as Map<String, dynamic>?;

                  // Build UI for each payment
                  return Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: Text(
                              'Event Name: ${paymentData?['eventDetails']['eventName'] ?? 'N/A'}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Amount Paid: ${paymentData?['amountPaid'] ?? 'N/A'}'),
                              Text(
                                  'Event Date: ${paymentData?['eventDetails']['eventDate'] ?? 'N/A'}'),
                              Text(
                                  'Remaining: ${paymentData?['eventDetails']['remaining'] ?? 'N/A'}'),
                              Text(
                                  'Slot: ${paymentData?['eventDetails']['slot'] ?? 'N/A'}'),
                              Text(
                                  'User Name: ${paymentData?['userName'] ?? 'N/A'}'),
                            ],
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              // Show confirmation dialog
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Delete Event'),
                                    content: const Text(
                                        'Are you sure you want to delete this event?'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          // Close the dialog
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          // Delete the event
                                          FirebaseFirestore.instance
                                              .collection('payments')
                                              .doc(paymentDocs[index].id)
                                              .delete();
                                          // Close the dialog
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    ),
  );
}
}