import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tfnd_app/themes/color.dart';
import 'package:tfnd_app/widgets/reusable_outlined_button.dart';

class Payment extends StatefulWidget {
  @override
  _PaymentState createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  final TextEditingController _paymentController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? payment;
  void _savePayment() {
    String payment = _paymentController.text.trim();
    if (payment.isNotEmpty) {
      _firestore
          .collection('Basicsubcriptionpayment')
          .doc('r8Uy0h8lgq31yXmwkQZq')
          .update({
        'amount': payment,
      }).then((value) {
        _paymentController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          
        
         const SnackBar(
          backgroundColor: AppColor.btnColor,
          content: Text('Payment updated successfully',style: TextStyle(color: Colors.black),)),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
             backgroundColor: AppColor.btnColor,
            content: Text('Failed to update payment: $error', style: TextStyle(color: Colors.black))),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
     const    SnackBar(
     backgroundColor: AppColor.btnColor,
      content: Text('Please enter subscription amount',style: TextStyle(color: Colors.black))
     ));
    }
  }

  void _getPaymentData() {
    _firestore.collection('Basicsubcriptionpayment').snapshots().listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        // Assuming only one payment document for simplicity
        String paymentAmount = snapshot.docs.first.get('amount');
        setState(() {
          _paymentController.text = paymentAmount;
        });
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getPaymentData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subcription Payment', style: TextStyle(color: AppColor.blackColor),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            TextField(
              keyboardType: TextInputType.number,
              controller: _paymentController,
              decoration: InputDecoration(
                  labelText: 'Subcription Amount',
                  hintText: '${_paymentController.text} AED'),
            ),
           const  SizedBox(height: 20),

           ReusableOutlinedButton(title: 'Save Amount', onTap: () {  _savePayment(); },
            
           )
            
          ],
        ),
      ),
    );
  }
}
