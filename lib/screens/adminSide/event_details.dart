// Import necessary packages and libraries
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mailer/mailer.dart' as mailer;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:tfnd_app/screens/adminSide/edit_event.dart';
import 'package:tfnd_app/widgets/const.dart';
import 'package:tfnd_app/models/AddEventModel.dart';
import 'package:tfnd_app/models/AddUserModel.dart';
import 'package:http/http.dart' as http;
import 'package:tfnd_app/screens/adminSide/eventbooking_details.dart';
import 'package:tfnd_app/themes/color.dart';
import 'package:tfnd_app/widgets/reusable_outlined_button.dart';
import 'package:tfnd_app/widgets/reusable_text.dart';
import 'package:shortid/shortid.dart';
import 'package:uuid/uuid.dart';

class eventsDetailss extends StatefulWidget {
  final AddEventModel event; // Event data
  String UserEmail;
  final VoidCallback onDeleteSuccess;
  eventsDetailss(
      {super.key,
      required this.event,
      required this.UserEmail,
      required this.onDeleteSuccess});

  @override
  State<eventsDetailss> createState() => _eventsDetailState();
}

class _eventsDetailState extends State<eventsDetailss> {

  int likeCount = 9;
  bool isliked = false;
  int commentCount = 0;
  bool isAndroid = Platform.isAndroid;
  bool isIOS = Platform.isIOS;
  String? buttonText;
  String? containerText;
  void handleCommentCountUpdate(int? count) async {
    if (count != null) {
      setState(() {
        commentCount = count;
      });
      print("Comment count updated to: $count");
    } else {
      print("Error: Comment count is null");
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

  
  }

  // Map to trak liked status of posts
  Map<String, bool> postLikedStatus = {};
  // Controller for the ssost descrition text field
  TextEditingController descriptionController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  // Initialize state
  @override
  void initState() {
    handleCommentCountUpdate(commentCount);

    super.initState();

    postLikedStatus[widget.event.uid.toString()] = false;
    getUserData(widget.UserEmail);
    print(" Email is--${widget.UserEmail}");
    print(" event is--${widget.event.uid}");
  }

 

  final TextEditingController _cardController = TextEditingController();

  Map<String, dynamic>? paymentIntent;
  var SECRET_KEY =
      'sk_test_51MRaTJF6Z1rhh5U4coAffyEf0hQrV820sQzwuAo7xBKpvGw0mBaz6pNCBtXrZoYTJZxH9uIZCxK7rEAKUKK3VZPA00pGIqUKA1';

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

  savePaymentDetails() async {
    try {
      print("user data =${userData}");
      if (userData != null) {
        await FirebaseFirestore.instance.collection('payments').add({
          'userName': userData!.name.toString(),
          'amountPaid': widget.event.price,
          'eventDetails': {
            'eventName': widget.event.name,
            'eventDate': widget.event.date,
          },
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
      paymentIntent = await createPaymentIntent('${widget.event.price}', 'USD');
      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                  paymentIntentClientSecret: paymentIntent!['client_secret'],
                  style: ThemeMode.dark,
                  merchantDisplayName: 'mubeen'))
          .then((value) {});

      displayPaymentSheet();
      savePaymentDetails();
    } catch (e, s) {
      print('exception:$e$s');
    }
  }

  displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) {
        showDialog(
            context: context,
            builder: (_) => const AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                          Text("   Payment Successful"),
                        ],
                      ),
                    ],
                  ),
                ));
        paymentIntent = null;
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

  calculateAmount(String amount) {
    final calculatedAmount = (int.parse(amount)) * 100;
    return calculatedAmount.toString();
  }

  Map<String, int> commentCounts = {};
  Future<void> _showDeleteConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Event', style: TextStyle(color: AppColor.btnColor),),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this event?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel',  style: TextStyle(color: AppColor.blackColor, fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: AppColor.btnColor, fontWeight: FontWeight.bold),),
              
              onPressed: () {
                // For example: call a method to delete the event and navigate back
                _deleteEventAndNavigateBack();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteEventAndNavigateBack() {
    deleteEvent(widget.event.uid.toString());
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      await FirebaseFirestore.instance
          .collection(
              'adminevents') // Assuming your events collction name is 'events'
          .doc(eventId) // Document ID of the event to delete
          .delete();
      print('Event deleted successfully');
      widget.onDeleteSuccess();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          
          content: Text(
            'Event deleted successfully',
            style: TextStyle(color: AppColor.blackColor),
          ),
          backgroundColor: AppColor
              .btnColor, // Customize the background color if needed
        ),
      );
    } catch (error) {
      print('Error deleting event: $error');
      // Handle error gracefully, if needed
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
        appBar: AppBar(
          backgroundColor: AppColor.bgColor,
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
                               // fit: BoxFit.fitWidth))
                            ))
                      ),
                // Displaying event details
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                  child: Container(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Displaying event date and location
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ReusableText(
                                  title: '${widget.event.date}',
                                  color: AppColor.blackColor,
                                  weight: FontWeight.bold,
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                ReusableText(
                                  title: "Time ${widget.event.time}",
                                  color: Colors.grey,
                                  weight: FontWeight.bold,
                                  size: 10,
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                ReusableText(
                                  title: wrapText(widget.event.Location, 35),
                                  color: AppColor.textColor,
                                  weight: FontWeight.bold,
                                  size: 10,
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
                              size: 11,
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
                        const SizedBox(
                          height: 20,
                        ),
  ReusableOutlinedButton(
                            title: " Event Booking Details ",
                            onTap: () {
_handleLearnMoreButton() ;
                               Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (BuildContext context) =>
                                    EventsbookingDetailss(
                                      event: widget.event,
                                      UserEmail: '',
                                    
                                    ),
                                  ),);
                           
                            }),

                         const   SizedBox(height: 10,),

                        ReusableOutlinedButton(
                            title: "Update Event ",
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Editevent(
                                    uid: widget.event.uid.toString(),
                                    image: widget.event.image.toString(),
                                    useremail: widget.UserEmail,
                                    description:
                                        widget.event.discription.toString(),
                                    eventname: widget.event.name.toString(),
                                    address: widget.event.Location.toString(),
                                    price: widget.event.price.toString(),
                                    time: widget.event.time.toString(),
                                    date: widget.event.date.toString(),
                                    onDeleteSucces: () {
                                      Navigator.pop(context);
                                    },
                                    slots: widget.event.slot.toString(),
                                  ), // Replace `NewScreen()` with the screen you want to navigate to
                                ),
                              );
                            }),
                        const SizedBox(
                          height: 10,
                        ),

                        ReusableOutlinedButton(
                            title: "Delete Event ",
                            onTap: () {
                              _showDeleteConfirmationDialog();
                            }),
                        const SizedBox(
                          height: 5,
                        ),
                        // ElevatedButton(
                        //     onPressed: () {}, child: const Text("mubeen")),
                      ],
                    ),
                  ),
                ),
                // Displaying posts related to the event
                const SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        ));
  }

  // Function to show the booking dialog
  void showBookingDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(
              child: Text(
            'Event Booking',
            style: TextStyle(color: AppColor.primaryColor),
          )),
          content: Container(
            height: 120,
            child: Column(children: [
              const ReusableText(
                title: "Bookings",
                color: AppColor.blackColor,
                weight: FontWeight.bold,
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Displaying total slots
                    Column(
                      children: [
                        const ReusableText(
                          title: "Total Slots",
                          color: AppColor.textColor,
                          weight: FontWeight.bold,
                          size: 12,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        ReusableText(
                          title: '${widget.event.slot}',
                          color: AppColor.primaryColor,
                          weight: FontWeight.bold,
                          size: 18,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    // Displaying remaining slots
                    Column(
                      children: [
                        const ReusableText(
                          title: "Remaining Slots",
                          color: AppColor.textColor,
                          weight: FontWeight.bold,
                          size: 14,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        ReusableText(
                          title: widget.event.remaining.toString(),
                          color: AppColor.darkTextColor,
                          weight: FontWeight.bold,
                          size: 18,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ]),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.black),
              ),
            ),
            TextButton(
              onPressed: () async 
              { 
                await makePayment();
                // await sendEmailToCurrentUser(widget.UserEmail);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(
                'Proceed to Payment',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColor.primaryColor),
              ),
            ),
          ],
        );
      },
    );
  }

  // Function to update the user profile after successful booking
  Future<void> updateUserProfile() async {
    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('adminevents')
          .where('uid', isEqualTo: widget.event.uid)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        await doc.reference.update({
          'date': widget.event.date,
          'uid': widget.event.uid,
          'discription': widget.event.discription,
          'address': widget.event.date,
          'image': widget.event.image,
          'location': widget.event.Location,
          'name': widget.event.name,
          'price': widget.event.price,
          'slot': widget.event.slot,
          'remaining': (widget.event.remaining != null)
              ? (int.parse(widget.event.remaining.toString()) - 1).toString()
              : null,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor:AppColor.btnColor,
            content: Text('Profile updated successfully!', style: TextStyle(color: Colors.black),),
          
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
             backgroundColor:AppColor.btnColor,
            content: Text('User not found!', style: TextStyle(color: Colors.black)),
          ),
        );
      }
    } catch (error) {
      print('Error updating profile: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            backgroundColor:AppColor.btnColor,
          content: Text('Failed to update profile. Please try again.',  style: TextStyle(color: Colors.black)),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

// Function to show a dialog for posting andviewing comments
}
