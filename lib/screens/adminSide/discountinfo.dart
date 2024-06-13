import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tfnd_app/themes/color.dart';

class Discountinfo extends StatefulWidget {
  @override
  _DiscountinfoScreenState createState() => _DiscountinfoScreenState();
}

class _DiscountinfoScreenState extends State<Discountinfo> {
  TextEditingController? _searchController;
  Stream<QuerySnapshot>? _paymentStream;
  List<DocumentSnapshot> _filteredPaymentDocs = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _paymentStream = FirebaseFirestore.instance
        .collection('ScannedBusinessDetails')
        .snapshots();
  }

  @override
  void dispose() {
    _searchController?.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.bgColor,
        title: Text('Discount Info'),
      ),
      body: Column(
        children: [
          Expanded(
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
                    child: CircularProgressIndicator(),
                  );
                }

                _filteredPaymentDocs = snapshot.data!.docs;

                return SingleChildScrollView(
                  scrollDirection:Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      horizontalMargin: 10,
                      columnSpacing: 10,
                      dataRowHeight: 56,
                      headingRowHeight: 56,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                      ),
                      columns: [
                        DataColumn(
                          label: GestureDetector(
                            child: const Text('Business Name'),
                            
                          ),
                        ),
                        const DataColumn(
                          label: Divider(),
                        ),
                        DataColumn(
                          label: GestureDetector(
                            child: Text('User'),
                           
                          ),
                        ),
                       const  DataColumn(
                          label: Divider(),
                        ),
                        DataColumn(
                          label: GestureDetector(
                            child: const  Text('Discount'),
                         
                          ),
                        ),
                      const   DataColumn(
                          label: Divider(
                            height: 1,
                          ),
                        ),
                        DataColumn(
                          label: GestureDetector(
                            child: const Padding(
                              padding:  EdgeInsets.only(left: 20),
                              child: Center(child: Text('Date')),
                            ),
                          
                          ),
                        ),
                      ],
                      rows: _filteredPaymentDocs.map((paymentDoc) {
                        Map<String, dynamic>? paymentData =
                            paymentDoc.data() as Map<String, dynamic>?;
                        return DataRow(
                          color: MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) {
                              // Add alternating row colors
                              return _filteredPaymentDocs.indexOf(paymentDoc) %
                                          2 ==
                                      0
                                  ? Colors.grey[200]
                                  : null;
                            },
                          ),
                          cells: [
                            DataCell(
                              Text(
                                '${paymentData?['businessName'] ?? 'N/A'}',
                                style: const  TextStyle(
                                  color: Colors.black,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                          const   DataCell(
                              Divider(),
                            ),
                            DataCell(
                              Text(
                                '${paymentData?['email'] ?? 'N/A'}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                           const  DataCell(
                              Divider(),
                            ),
                            DataCell(
                              Text(
                                '${paymentData?['discount'] ?? 'N/A'}%',
                                style: const TextStyle(
                                  color: Colors.black,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                           const  DataCell(
                              Divider(),
                            ),
                            DataCell(
                              Text(
                                '${paymentData?['timestamp'] ?? 'N/A'}'
                                    .toLowerCase(),
                                style: const  TextStyle(
                                  color: Colors.black,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
