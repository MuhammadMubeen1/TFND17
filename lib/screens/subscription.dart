import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mailer/mailer.dart' as mailer;
import 'package:mailer/smtp_server.dart';
import 'package:tfnd_app/themes/color.dart';
import 'package:uuid/uuid.dart';
import 'package:shortid/shortid.dart';

class SubscriptionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? paymentIntent;
  String? tum;
  String collectionPath = 'scan_records';
  Future<void> showSubscriptionPopup(BuildContext context, String email) async {
    bool isLoading = false;

    // Fetch payment amount
    QuerySnapshot querySnapshot =
        await _firestore.collection('Basicsubcriptionpayment').get();
    if (querySnapshot.docs.isNotEmpty) {
      tum = querySnapshot.docs.first.get('amount');
    }

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(
            child: Column(
              children: [
                Text(
                  "Subscribe now to gain access",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                SizedBox(
                  height: 30,
                ),
                Image(
                  height: 120,
                  image: AssetImage("assets/images/tfndd.png"),
                ),
              ],
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Center(
                child: Text(
                  "Pay $tum AED per month",
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w400),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: 220,
                child: const Center(
                  child: Text(
                    "Get access to a great variety of content posts and events for entertainment and knowledge. Explore numerous businesses and their products to enjoy great discounts. Subscribe now and elevate your experience!",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        color: AppColor.textColor),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              StatefulBuilder(
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

                                await makePay(context, email);

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
                                "Proceed",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                      ),
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
                      ))
                    ],
                  );
                },
              ),
            ]),
          ),
        );
      },
    );
  }

  Future<void> makePay(BuildContext context, String email) async {
    paymentIntent = await createPaymentIntent('$tum', 'AED');
    await Stripe.instance
        .initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
                paymentIntentClientSecret: paymentIntent!['client_secret'],
                style: ThemeMode.dark,
                merchantDisplayName: 'muben'))
        .then((value) {});

    displayPaymentSheet(context, email);
  }

  displayPaymentSheet(BuildContext context, String email) async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) async {
        await updateUserProfile(email);
        await savePaymentDetails(email);
        updateBusinessScanCount(email);

        Fluttertoast.showToast(
          msg: 'Payment successful.',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 3,
          backgroundColor: AppColor.btnColor,
          textColor: Colors.black,
          fontSize: 16.0,
        );

        await sendEmail(email, tum!);

        await Fluttertoast.showToast(
          msg: 'A confirmation email has been sent to you',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 6,
          backgroundColor: AppColor.btnColor,
          textColor: Colors.black,
          fontSize: 16.0,
        );
      }).onError((error, stackTrace) {
        print('Error is:--->$error $stackTrace');
      });
    } on StripeException catch (e) {
      print('Error is:---> $e');
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          content: Text("Cancelled"),
        ),
      );
    } catch (e) {
      print('$e');
    }
  }

  var SECRET_KEY =
      'sk_test_51OKN7TDJfrTnX036zTG8cFoHLTvBqzpGDrUIwWEAZzRMaWGwcctMe9LV3fhLPEkyCXgQhUC6gOzn9p9WVvhY7ExE00OFgCshKL';

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

  Future<void> updateUserProfile(String email) async {
    try {
      DateTime currentTimestamp = DateTime.now();
      String formattedTimestamp =
          DateFormat('dd-MM-yyyy').format(currentTimestamp);
      DateTime nextDueDate = currentTimestamp.add(Duration(days: 30));
      String formattedNextDueDate =
          DateFormat('dd-MM-yyyy').format(nextDueDate);
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('RegisterUsers')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        await doc.reference.update({
          'subscription': 'paid',
          'firstDate': formattedTimestamp,
          'nextDueDate': formattedNextDueDate,
          'counter':'1'
        });
      }
    } catch (error) {
      print('Error updating profile: $error');
    }
  }

  Future<void> updateBusinessScanCount(String userEmail) async {
    try {
      // Query to find all documents where userEmail matches the provided email
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(collectionPath)
          .where('userEmail', isEqualTo: userEmail)
          .get();

      // Check if any document matches the query
      if (querySnapshot.docs.isNotEmpty) {
        // Iterate through all matching documents
        for (DocumentSnapshot documentSnapshot in querySnapshot.docs) {
          // Get the current scanCount

          print("hellow world..... $userEmail");
          // Update the document with incremented scanCount
          await documentSnapshot.reference.update({
            'scanCount': 0,
          });
        }

        print('All business scan counts updated successfully');
      } else {
        print('No matching documents found for userEmail: $userEmail');
      }
    } catch (error) {
      print('Error updating business scan counts: $error');
    }
  }

  Future<void> savePaymentDetails(String email) async {
    try {
      DateTime currentTimestamp = DateTime.now();
      String formattedTimestamp =
          DateFormat('dd-MM-yyyy').format(currentTimestamp);

      await FirebaseFirestore.instance.collection('BasicSubcriptionInfo').add({
        'userName': email,
        'date': formattedTimestamp,
        'amount': tum,
      });
    } catch (error) {
      print('Error saving payment details: $error');
    }
  }

  Future<bool> sendEmail(String email, String amount) async {
    try {
      String currentDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
      var uuid = Uuid();
      String uniqueId = uuid.v1();
      String shortUniqueId = shortid.generate();
      String username = 'almubeen104@gmail.com'; // Your email
      String password = 'xifzfoosrmurbxqj'; // Your email password
      final smtpServer = gmail(username, password);
      final message = mailer.Message()
        ..from = mailer.Address(username)
        ..recipients.add(email)
        ..subject = "TFND Monthly Subscription"
        ..html = "<p>Dear User,</p>"
            "<p>Welcome to TFND.</p>"
            "<p>We have received payment from you for monthly subscription of TFND starting on $currentDate. (ID: $shortUniqueId)</p>"
            "<p>Payment: AED $amount</p>"
            "<p>Enjoy great discounts!</p>"
            "<p>We wish you all the best.</p>"
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
