
import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mailer/mailer.dart' as mailer;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:tfnd_app/models/AddEventModel.dart';
import 'package:tfnd_app/models/AddUserModel.dart';
import 'package:http/http.dart' as http;
import 'package:tfnd_app/themes/color.dart';
import 'package:tfnd_app/widgets/reusable_text.dart';
import 'package:shortid/shortid.dart';
import 'package:uuid/uuid.dart';

class EventsbookingDetailss extends StatefulWidget {
  final AddEventModel event; // Event data
  String UserEmail;

  EventsbookingDetailss({
    super.key,
    required this.event,
    required this.UserEmail,
  });

  @override
  State<EventsbookingDetailss> createState() => _EventsbookingDetailssState();
}

class _EventsbookingDetailssState extends State<EventsbookingDetailss> {


  bool isAndroid = Platform.isAndroid;
  bool isIOS = Platform.isIOS;
  String? buttonText;
  String? containerText;
  List<DocumentSnapshot> _filteredPaymentDocs = [];
  Future<void> _handleLearnMoreButton() async {
    setState(() {
      isLoading = true;
    });
    await Future.delayed(Duration(seconds: 3));

    setState(() {
      isLoading = false;
    });

  
  }

 
  TextEditingController descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  Stream<QuerySnapshot>? _paymentStream;
  // Initialize state
  @override
  void initState() {
    super.initState();
    setState(() {
    didChangeDependencies();
      
    });
   _paymentStream = FirebaseFirestore.instance
        .collection('payments')
        .snapshots();

  }
void didChangeDependencies() {
  super.didChangeDependencies();
_getCurrentEventData();
}
  final TextEditingController _cardController = TextEditingController();

  AddUserModel? userData;

  String wrapText(String? text, int lineLength) {
    if (text == null) {
      return '';
    }

    if (text.length <= lineLength) {
      return text;
    } else {
      int breakIndex = text.lastIndexOf(' ', lineLength);
      if (breakIndex == -1) {
        breakIndex = lineLength;
      }
      return text.substring(0, breakIndex) +
          '\n' +
          wrapText(text.substring(breakIndex).trim(), lineLength);
    }
  }
  AddEventModel? eventData ;
Future<void> _getCurrentEventData() async {
  try {
    // Listen for changes to the document
    FirebaseFirestore.instance
        .collection('adminevents')
        .where('uid', isEqualTo: widget.event.uid)
        .snapshots()
        .listen((eventSnapshot) {
      if (eventSnapshot.docs.isNotEmpty) {
        // Assuming there's only one document matching the UID
        DocumentSnapshot eventDoc = eventSnapshot.docs.first;

        // Retrieve the data from the document and cast it to Map<String, dynamic>
        Map<String, dynamic> eventDataMap =
            eventDoc.data() as Map<String, dynamic>;

        // Convert Firestore data to AddEventModel object
        AddEventModel newEventData =
            AddEventModel.fromJson(eventDataMap);

        // Update state using setState
        setState(() {
          eventData = newEventData;
        });

        // Now you can use the eventData as the current event data
        print('Current event data: ${eventData!.remaining}');
      } else {
        print('Event with UID ${widget.event.uid} not found');
      }
    });
  } catch (e) {
    print('Error fetching current event data: $e');
  }
}





  @override
  Widget build(BuildContext context) {
    if (isAndroid) {
      buttonText = "Book this Event";
      containerText = "Android Device Text";
    } else {
      buttonText = "Learn More";
      containerText = "iOS Device Text";
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColor.bgColor,
        iconTheme: const IconThemeData(
          color: AppColor.hintColor, // Change this color to the desired one
        ),
        centerTitle: true,
        title: const ReusableText(
          title: "Event Booking ",
          color: AppColor.blackColor,
          size: 20,
          weight: FontWeight.w500,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
            child: Stack(
          children: [
            Column(
              children: [
                widget.event.image == null
                    ? Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            image: const DecorationImage(
                                image: NetworkImage(
                                    "https://d2x3xhvgiqkx42.cloudfront.net/12345678-1234-1234-1234-1234567890ab/651c25b0-2d60-43c8-addf-1df2fd575568/2021/08/16/455d8bde-5940-4005-a79a-56005926c158/65b4998a-5202-4a77-af1e-c646f5fc36e1.png"),
                                fit: BoxFit.contain)),
                      )
                    : Container(
                        height: 190,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(10.0),
                            bottomRight: Radius.circular(10.0),
                          ),

                          // Adjust the value as needed
                          image: DecorationImage(
                            image: NetworkImage(widget.event.image.toString()),
                            fit: BoxFit.fill,
                          ),
                          color: AppColor.bgColor,
                        ),
                      ),
              ],
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 150,
                ),
                child: Container(
            height: MediaQuery.of(context).size.height,
                  width: 330,
                  decoration: const BoxDecoration(
                    color: AppColor.bgColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 15,
                      ),
                      Center(
                          child: Text(
                        widget.event.name.toString(),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                      const SizedBox(
                        height: 5,
                      ),
                      Center(
                        child: Text(
                          "Price: ${widget.event.price.toString()} AED  ",
                          style: const TextStyle(
                            color: Color(0xffFF72AD),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Center(
                        child: Text(
                          "${widget.event.date.toString()} ${widget.event.time}",
                          style: const TextStyle(
                            color: Color(0xffB7954F),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Center(
                        child: Container(
                          width: 280,
                          child: Text(
                            "${widget.event.Location}",
                            style: const TextStyle(
                              color: AppColor.textColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Total Slots: ${eventData?.slot ?? ""}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 10),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      Text("Booked Slots: ${eventData?.booked ??""}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 10)),
                      const SizedBox(
                        height: 3,
                      ),
                      Text("Remaining Slots: ${eventData?.remaining?? ""} ",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 10)),
                      const SizedBox(
                        height: 15,
                      ),
                      Container(
                        height: 50,
                        width: 300,
                        child: Center(
                            child: Text(
                          "Total Revenue: ${eventData?.revenue??""} AED ",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        )),
                        decoration: BoxDecoration(
                          color: const Color(0xffE597A7),
                          borderRadius: BorderRadius.circular(10.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300,
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset:
                                  Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      const Text(
                        "Booking Details ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
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
  _filteredPaymentDocs = snapshot.data!.docs.where((paymentDoc) {
        Map<String, dynamic>? paymentData =
            paymentDoc.data() as Map<String, dynamic>?;

        // Assuming the event UID is stored in the 'eventUid' field of paymentData
        return paymentData?['eventDetails']['uid'] == widget.event.uid;
      }).toList();

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      horizontalMargin: 8,
                      columnSpacing: 10,
                      dataRowHeight: 50,
                      headingRowHeight: 40,
                      decoration: BoxDecoration(
                        color: AppColor.bgColor,
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      columns: [
                        DataColumn(
                          label: GestureDetector(
                            child: const Text('DATE', style: TextStyle(color: Colors.black45, ),),
                            
                          ),
                        ),
                        const DataColumn(
                          label: Divider(),
                        ),
                        DataColumn(
                          
                          label: GestureDetector(
                            child: const Text('USER',style: TextStyle(color: Colors.black45,),),
                           
                          ),
                        ),
                       const  DataColumn(
                          label: Divider(),
                        ),
                        DataColumn(
                          label: GestureDetector(
                            child: const  Text('SLOTS', style: TextStyle(color: Colors.black45, ),),
                         
                          ),
                        ),
                      const   DataColumn(
                          label: Divider(
                            height: 1,
                          ),
                        ),
                      DataColumn(
                          label: GestureDetector(
                            child: const  Text('AED', style: TextStyle(color: Colors.black45, ),),
                         
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
                                '${paymentData?['eventDetails']["count"] ?? 'N/A'}',
                             
                                style: const  TextStyle(
                                
                                color: Colors.black45,
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
                                      
                                color: Colors.black45,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                           const  DataCell(
                              Divider(),
                            ),
                            DataCell(
                              Text(
                               '${paymentData?['eventDetails']["number"] ?? 'N/A'}',
                                style: const TextStyle(
                                  color: Colors.black45,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                           const  DataCell(
                              Divider(),
                            ),
                            DataCell(
                              Text(
                                '${paymentData?['amountPaid']  ?? 'N/A'}'
                                    .toLowerCase(),
                                style: const  TextStyle(
                                 
                                   color: Colors.black45,
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
                   
                   
                 const   SizedBox(height: 30,),
                   
                    ],
                  ),
                ),
              ),
            ),
          ],
        )),
      ),
    );
  }
}
