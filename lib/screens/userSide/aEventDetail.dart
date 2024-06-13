// Import necessary packages and libraries
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:mailer/mailer.dart' as mailer;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tfnd_app/screens/subscription.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:tfnd_app/models/AddEventModel.dart';
import 'package:tfnd_app/models/AddUserModel.dart';
import 'package:http/http.dart' as http;
import 'package:tfnd_app/themes/color.dart';
import 'package:tfnd_app/widgets/reusable_text.dart';
import 'package:shortid/shortid.dart';
import 'package:uuid/uuid.dart';
 
class EventsDetail extends StatefulWidget {
  final AddEventModel event; // Event data
  String UserEmail;

  EventsDetail({super.key, required this.event, required this.UserEmail});

  @override
  State<EventsDetail> createState() => _eventsDetailState();
}

class _eventsDetailState extends State<EventsDetail> {
  
  bool isIOS = Platform.isIOS;
  bool isPaymentInProgress = false;
  String? buttonText;
  String? containerText;
  bool isWaiting = false;
    bool _isSubscribing = false;
    String? isPaid;
    final SubscriptionService _subscriptionService = SubscriptionService();
  

  // Map to trak liked status of posts
  Map<String, bool> postLikedStatus = {};
  // Controller for the ssost descrition text field
  TextEditingController descriptionController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  // Initialize state
  @override
  void initState() {
   
   listenToUserData (widget.UserEmail);
getCurrentEventData() ;
    setState(() {
      isLoading = false;
    });



    postLikedStatus[widget.event.uid.toString()] = false;
    getUserData(widget.UserEmail);
    print(" Email is--${widget.UserEmail}");
    print(" event is--${widget.event.uid}");
  }



  AddEventModel? eventData ;


Future<void> getCurrentEventData() async {
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
        Map<String, dynamic> eventDataMap = eventDoc.data() as Map<String, dynamic>;

        // Convert Firestore data to AddEventModel object
     eventData = AddEventModel.fromJson(eventDataMap);

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



 
  final TextEditingController _cardController = TextEditingController();

  Map<String, dynamic>? paymentIntent;
  var SECRET_KEY =
      'sk_test_51OKN7TDJfrTnX036zTG8cFoHLTvBqzpGDrUIwWEAZzRMaWGwcctMe9LV3fhLPEkyCXgQhUC6gOzn9p9WVvhY7ExE00OFgCshKL';

  AddUserModel? userData;
  bool isLiked = false;

  Future<AddUserModel?> getUserData(String currentUserEmail) async {
    try {
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('RegisterUsers')
          .where('email', isEqualTo: currentUserEmail)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        userData = AddUserModel.fromJson(
            userSnapshot.docs.first.data() as Map<String, dynamic>);

        return userData;
      }
    } catch (e) {
      print("Error fetching user data: $e");
      return null;
    }
  }

  // Function to save payment details in Firestore
  savePaymentDetails() async {
    try {
      print("user data =${userData}");
      if (userData != null) {
         String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
        await FirebaseFirestore.instance.collection('payments').add({
          'userName': userData!.name.toString(),
          'amountPaid': widget.event.price,
          'eventDetails': {
            'eventName': widget.event.name,
            'eventDate': widget.event.date,
            'slot': widget.event.slot,
            'remaining': widget.event.remaining,
            "uid":widget.event.uid,
             'count':formattedDate,
             'number':'1',
              
         
          },
             "email":widget.UserEmail,
            
          //  'count': FieldValue.increment(1),
          'timestamp': FieldValue.serverTimestamp(),


        });
        updateUserProfile();

        const SnackBar(
          padding: EdgeInsets.all(10),
          backgroundColor: AppColor.blackColor,
          content: Text(
            'Booked Successfully!',
            style: TextStyle(color: AppColor.btnColor),
          ),
          duration: Duration(seconds: 2),
        );

        print("user data =${userData}");
        await FirebaseFirestore.instance
            .collection('RegisterUsers')
            .doc(userData!.email)
            .update({
          'bookedEvents': FieldValue.arrayUnion([widget.event.name])
        });

      }
    } catch (error) {
      print('Error saving payment details: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  String wrapText(String? text, int lineLength) {
    if (text == null) {
      return ''; // Return empty string if the text is null
    }

    if (text.length <= lineLength) {
      return text; // If the text is shorter than the line length, return it as is
    } else {
      int breakIndex = text.lastIndexOf(
          ' ', lineLength); // Find the last space before the line length
      if (breakIndex == -1) {
        breakIndex =
            lineLength; // If there are no spaces, break at the line length
      }
      return text.substring(0, breakIndex) +
          '\n' +
          wrapText(text.substring(breakIndex).trim(), lineLength);
    }
  }

  CollectionReference postsCollection =
      FirebaseFirestore.instance.collection('Posts');
  Future<int> getCommentCount(String postId) async {
    try {
      var querySnapshot =
          await postsCollection.doc(postId).collection('comments').get();

      return querySnapshot.size;
    } catch (e) {
      print("Error fetching comment count: $e");
      return 0;
    }
  }

  // Function to initiate the payment process
  Future<void> makePayment() async {
    try {
      setState(() {});
      setState(() {
        isLoading = true;
        isPaymentInProgress = true;
      });
      paymentIntent = await createPaymentIntent('${widget.event.price}', 'AED');
      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                  paymentIntentClientSecret: paymentIntent!['client_secret'],
                  style: ThemeMode.dark,
                  merchantDisplayName: 'mubeen'))
          .then((value) {});

      displayPaymentSheet();

      // savePaymentDetails();
    } catch (e, s) {
      print('exception:$e$s');
      setState(() {
        isPaymentInProgress = false;
        setState(() {
          isLoading = false;
        });
      });
    }
  }

  // Function to display the payment sheet
  displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) {
        print('Payment successful'); // Add this print statement
        // _showApprovalNotification(); // Push local notification
           Fluttertoast.showToast(
        msg: 'Event Booked successfully.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 4,
        backgroundColor: AppColor.btnColor,
        textColor: AppColor.blackColor,
        fontSize: 16.0,
      );
        _handleLearnMoreButton();
        paymentIntent = null;
        savePaymentDetails();


   
   
      }).onError((error, stackTrace) {
        print('Error is:--->$error $stackTrace');
      });
    } on StripeException catch (e) {
      print('Error is:---> $e');
      showDialog(
          context: context,
          builder: (_) => const AlertDialog(
                content: Text("Cancelled "),
              ));
    } catch (e) {
      print('$e');
    }
  }

  // Function to create a payment intent using Stripe API
  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card'
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $SECRET_KEY',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      print('Payment Intent Body->>> ${response.body.toString()}');
      return jsonDecode(response.body);
    } catch (err) {
      print('err charging user: ${err.toString()}');
    }
  }

  // Function to calculate the payment amount
  calculateAmount(String amount) {
    final calculatedAmount = (int.parse(amount)) * 100;
    return calculatedAmount.toString();
  }



  Map<String, int> commentCounts = {};
  
  Future<void> listenToUserData(String currentUserEmail) async {
    try {
      FirebaseFirestore.instance
          .collection('RegisterUsers')
          .where('email', isEqualTo: currentUserEmail)
          .snapshots()
          .listen((QuerySnapshot userSnapshot) {
        if (userSnapshot.docs.isNotEmpty) {
          userData = AddUserModel.fromJson(
              userSnapshot.docs.first.data() as Map<String, dynamic>);

          if (userData!.subscription!.isNotEmpty) {
            setState(() {
              isPaid = userData!.subscription;
            });
            print("Subscriptionsstatus: $isPaid");
          } else {
            print("No subscription found");
          }
        }
      });
    } catch (e) {
      print("Error listening to user data: $e");
    }
  }



  @override
  Widget build(BuildContext context) {
    DateTime eventDate =
        DateFormat('d MMMM yyyy').parse(widget.event.date.toString());

    // Check if the event date is in the past
    DateTime currentDate = DateTime.now();
    bool isEventDatePassed = currentDate.isAfter(eventDate);

    return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(
            color: AppColor.hintColor, // Change this color to the desired one
          ),
          centerTitle: true,
          title: const ReusableText(
            title: "Event Details",
            color: AppColor.blackColor,
            size: 20,
            weight: FontWeight.w500,
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Displaying event image
                widget.event.image == null
                    ? Container(
                        height: 200,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImage(
                                    "https://d2x3xhvgiqkx42.cloudfront.net/12345678-1234-1234-1234-1234567890ab/651c25b0-2d60-43c8-addf-1df2fd575568/2021/08/16/455d8bde-5940-4005-a79a-56005926c158/65b4998a-5202-4a77-af1e-c646f5fc36e1.png"),
                                fit: BoxFit.contain)),
                      )
                    : Container(
                        height: 190,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image:
                                    NetworkImage(widget.event.image.toString()),
                               // fit: BoxFit.fill
                                )),
                      ),
                // Displaying event details
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                  child: Container(
                    child: Column(children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Displaying event date and location
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  // Function to launch Google Maps
                                },
                                child: ReusableText(
                                  title: '${widget.event.date}',
                                  color: AppColor.blackColor,
                                  weight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              ReusableText(
                                title: "Time ${widget.event.time?? 
                                ""}",
                                color: Colors.grey,
                                weight: FontWeight.bold,
                                size: 10,
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              GestureDetector(
                                onTap: () {
                                  _openInMap(); // Function to launch Google Maps
                                },
                                child: Row(
  children: [
   const  Icon(
      Icons.location_on, // This is the location icon
      color: AppColor.btnColor,
      size: 20,
    ),
    SizedBox(width: 5), // Adding some space between the icon and text
    ReusableText(
      title: wrapText(widget.event.Location, 30),
      color: AppColor.textColor,
      weight: FontWeight.bold,
      size: 10,
    ),
  ],


                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                            ],
                          ),
                          // Displaying event price
                          ReusableText(
                            title: "${widget.event.price} AED",
                            color: AppColor.btnColor,
                            weight: FontWeight.bold,
                            size: 12,
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 5,
                      ),

                      const Divider(),
                      const SizedBox(
                        height: 5,
                      ),
                      // Displaying event name and description
                      ReusableText(
                        title: '${widget.event.name}',
                        size: 17,
                        color: AppColor.darkTextColor,
                        weight: FontWeight.bold,
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      ReusableText(
                        title: '${widget.event.discription}',
                        size: 13,
                        color: AppColor.textColor,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      const Divider(),
                      if (!isEventDatePassed) ...[
                        const SizedBox(
                          height: 30,
                        ),
                 GestureDetector(
  onTap: () async {
    if (isPaid == "paid"){
      showBookingDialog();
    }
    else{
      if (!isWaiting) { // Add this condition
        isWaiting = true; // Set to true before calling the function
        await _subscriptionService.showSubscriptionPopup(context, widget.UserEmail);
        isWaiting = false; // Set to false after the function call is complete
      }
    }
  },

                          child: Container(
                            height: 50,
                            width: 250,
                            decoration: BoxDecoration(
                              color: AppColor.btnColor,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.5),
                                  offset: Offset(0, 3),
                                  blurRadius: 6,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                "Book this event",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                      ],
                    ]),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        ));
  }

  void showBookingDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: Center(
                child: Text(
                  
              widget.event.name.toString(),
              style: const  TextStyle(color: AppColor.btnColor, fontSize: 16, fontWeight: FontWeight.bold),
            )),
            content:  Container(
              height: 120,
              child: Column(children: [
                Center(
                  child: ReusableText(
                    title: widget.event.date,
                    color: AppColor.blackColor,
                    size: 12,
                    weight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5,),
                Center(
                  child: ReusableText(
                      size: 12,
                    title: widget.event.time,
                    color: AppColor.blackColor,
                    weight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Center(
                  child: Column(
                    children: [
                      const Center(
                        child: ReusableText(
                          title: "Remaining Slots",
                          color: AppColor.btnColor,
                          weight: FontWeight.bold,
                          size: 16,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      ReusableText(
                        title: eventData!.remaining,
                        color: AppColor.darkTextColor,
                        weight: FontWeight.bold,
                        size: 18,
                      ),
                    ],
                  ),
                )
              ]),
            ),
            actions: [
         
              if (int.parse(widget.event.remaining.toString()) > 0)
               


               Container(
  child: StatefulBuilder(
    builder: (BuildContext context, StateSetter setState) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.btnColor,
              textStyle: const TextStyle(fontSize: 18),
              minimumSize: const Size.fromHeight(40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: isLoading
                ? null
                : () async {
                    setState(() {
                      isLoading = true;
                    });

                    await makePayment();

                    setState(() {
                      isLoading = false;
                    });

                    Navigator.of(context).pop(); // Close the dialog
                  },
            child: isLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 35,
                        child: const CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Please Wait",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                : const Text(
                    "Proceed To Payemnt ",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
          
     
      const SizedBox(height: 20), // Spacer between buttons
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "Close",
                style: TextStyle(
                  color: AppColor.btnColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
            )
            ]
            );
            }
            )
            )
            ]
            );
      },
    );
  }
  


Future<bool> updateUserProfile() async {
  try {
    // Assuming 'adminevents' is the collection containing event documents
    QuerySnapshot eventQuerySnapshot = await FirebaseFirestore.instance
        .collection('adminevents')
        .where('uid', isEqualTo: widget.event.uid)
        .get();

    if (eventQuerySnapshot.docs.isNotEmpty) {
      // Assuming there's only one document matching the UID
      DocumentSnapshot eventSnapshot = eventQuerySnapshot.docs.first;

      int remainingSlots = int.parse(eventSnapshot['remaining']); // Convert to int

      if (remainingSlots > 0) {
        remainingSlots--; // Decrement remaining slots

        // Increment booked slots
     

        await eventSnapshot.reference.update({
          'remaining': remainingSlots.toString(),
    
        });
        
           int bookedSlots = int.parse(eventSnapshot['booked']);
        bookedSlots++;
        
          int eventPrice = int.parse(eventSnapshot['price']);
        int revenue = eventPrice * bookedSlots; // Convert back to string before update
          await eventSnapshot.reference.update({
       
          'booked': bookedSlots.toString(),
           'revenue': revenue.toString(),
        });
         // Conv
        // Update booked events for user

        return true; // Update successful
      } else {
        return false; // Slots are not available
      }
    } else {
      return false; // No event found with the given UID
    }
  } catch (error) {
    print('Error updating remaining slots: $error');
    return false; // Update failed
  }
}



  _openInMap() async {
    double latitude = 0.0; // Placeholder value, replace with actual latitude
    double longitude = 0.0; // Placeholder value, replace with actual longitude

    // Check if the event's location is provided
    if (widget.event.Location != null) {
      String apiKey = 'AIzaSyAlWLuEzszKgldMmuo9JjtKLxe9MGk75_k';
      String location = Uri.encodeComponent(widget.event.Location!);
      String apiUrl =
          'https://maps.googleapis.com/maps/api/geocode/json?address=$location&key=$apiKey';

      // Make a request to the geocoding API
      var response = await http.get(Uri.parse(apiUrl));

      // Parse the response
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          latitude = data['results'][0]['geometry']['location']['lat'];
          longitude = data['results'][0]['geometry']['location']['lng'];
        } else {
          throw 'Unable to geocode the address';
        }
      } else {
        throw 'Failed to fetch geocoding data';
      }

      // Construct the map URL with the latitude and longitude
      String mapUrl =
          'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

      // Check if the map application is installed, if not, launch the URL in a browser
      if (await canLaunch(mapUrl)) {
        await launch(mapUrl);
      } else {
        throw 'Could not launch $mapUrl';
      }
    } else {
      throw 'Event location is not provided';
    }
  }
Future<void> _handleLearnMoreButton() async {
    setState(() {
      isLoading = true;
    });
    await Future.delayed(Duration(seconds: 3));

    setState(() {
      isLoading = false;
    });

    sendEmail();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: AppColor.blackColor,
        content: Text(
          ' A confirmation email has been sent to you',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColor.btnColor),
        )));
  }

  
  Future<bool> sendEmail() async {
    try {
      // Generate a unique ID
      var uuid = Uuid();
      String uniqueId = uuid.v1();
      String shortUniqueId = shortid.generate();
      String username = 'almubeen104@gmail.com';
      String password = 'xifzfoosrmurbxqj';
      final smtpServer = gmail(username, password);
  bool _isSubscribing = false;
      // Constructing the URL with parameters
     

      final message = mailer.Message()
        ..from = mailer.Address(username)
        ..recipients.add(widget.UserEmail)
        ..subject = "${widget.event.name} Confirmation by TFND"
        ..html = "<p>Dear ${userData!.name}</p>"
            "<p>Welcome to TFND</p>"
            "<p>We have received payment from you for 1 slot at ${widget.event.name}.(ID:${shortUniqueId}) </p>"
            "<p>The venue of the event is ${widget.event.Location} </p>"
            "<p> Date: ${widget.event.date} </p>"
            "<p> Time: ${widget.event.time} </p>"
            "<p>Payment: ${widget.event.price} AED.</p>"
            "<p>We wish you an enjoyable event </p>"
           "<p>  </p>"
            "<p>TFND Team</p>";

      final sendReport = await mailer.send(message, smtpServer);
      print('Message sent: $sendReport');
      return true;
    } catch (error) {
      print('Error sending email: $error');
      return false;
    }
  }
  
  
  
}