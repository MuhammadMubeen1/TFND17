import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tfnd_app/screens/adminSide/buttom_navigation.dart';
import 'package:tfnd_app/themes/color.dart';
import 'package:tfnd_app/widgets/reusable_text.dart';

class aBusinessDetails extends StatefulWidget {
  final Map<String, dynamic> requestData;

  const aBusinessDetails({Key? key, required this.requestData})
      : super(key: key);

  @override
  State<aBusinessDetails> createState() => _aBusinessDetailsState();
}

class _aBusinessDetailsState extends State<aBusinessDetails> {
  bool _isApproveProcessing = false;
  bool _isRejectProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.bgColor,
        iconTheme: const IconThemeData(
          color: AppColor.hintColor,
        ),
        centerTitle: true,
        title: const ReusableText(
          title: "Business Details",
          color: AppColor.blackColor,
          size: 20,
          weight: FontWeight.w500,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
          
                Container(
                width: 300, // Adjust width and height as needed
                height: 160,
                decoration: BoxDecoration(
           borderRadius: BorderRadius.circular(20), // Adjust border radius as needed
          border: Border.all(color: AppColor.btnColor, width: 2),
            
          image: DecorationImage(
                 
            image: NetworkImage(widget.requestData['imageUrl']), // Provide the image URL here
          ),
                ),
              ),
             const  SizedBox(
                height: 30,
              ),
              Row(
                children: [
                
                  const Icon(
                    Icons.person_outline,
                    size: 25,
                    color: AppColor.hintColor,
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  ReusableText(
                    title: widget.requestData['userName'] ?? '',
                    size: 15,
                    color: AppColor.darkTextColor,
                  )
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              const Divider(),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  const Icon(
                    Icons.phone_outlined,
                    size: 25,
                    color: AppColor.hintColor,
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  ReusableText(
                    title: widget.requestData['phone'] ?? '',
                    size: 15,
                    color: AppColor.darkTextColor,
                  )
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              const Divider(),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  const Icon(
                    Icons.email_outlined,
                    size: 25,
                    color: AppColor.hintColor,
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  ReusableText(
                    title: widget.requestData['email'] ?? '',
                    size: 15,
                    color: AppColor.darkTextColor,
                  )
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              const Divider(),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  const Icon(
                    Icons.location_city_outlined,
                    size: 25,
                    color: AppColor.hintColor,
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: ReusableText(
                      title: widget.requestData['location'] ?? '',
                      size: 15,
                      color: AppColor.darkTextColor,
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              const Divider(),
              const SizedBox(
                height: 40,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
  children: [
    if (widget.requestData['status'] == 'rejected' ||
        widget.requestData['status'] == 'pending')
      Expanded(
        child: ElevatedButton(
          onPressed: _isApproveProcessing
              ? null
              : () {
                  setState(() {
                    _isApproveProcessing = true;
                  });
                  handleRequestStatus(
                    widget.requestData['requestId'], 'approved');
                     
              },
          child: _isApproveProcessing
              ? const CircularProgressIndicator(
                  color: Colors.black,
                )
              : const ReusableText(
                  title: "Approve",
                  color: Colors.black,
                  weight: FontWeight.bold,
                ),
          style: ButtonStyle(
            shape: MaterialStateProperty.all<OutlinedBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    18), // Adjust the radius as needed
                side: const BorderSide(
                    color: AppColor
                        .btnColor), // Adjust the color as needed
              ),
            ),
          ),
        ),
      ),
    const SizedBox(
      width: 25,
    ),
    if (widget.requestData['status'] == 'approved' ||
        widget.requestData['status'] == 'pending')
      Expanded(
        child: ElevatedButton(
          onPressed: _isRejectProcessing
              ? null
              : () {
                  setState(() {
                    _isRejectProcessing = true;
                  });
                  handleRequestStatus(
                      widget.requestData['requestId'], 'rejected');
              },
          style: ButtonStyle(
            shape: MaterialStateProperty.all<OutlinedBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    18), // Adjust the radius as needed
                side: const BorderSide(
                    color: AppColor
                        .btnColor), // Adjust the color as needed
              ),
            ),
          ),
          child: _isRejectProcessing
              ? const CircularProgressIndicator(
                  color: Colors.black,
                )
              : const Text(
                  "Reject",
                  style: TextStyle(
                    color: AppColor.btnColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
  ],
)            ],
          ),
        ),
      ),
    );
  }

 void handleRequestStatus(String requestId, String status) async {
  setState(() {
    if (status == 'approved') {
      _isApproveProcessing = true;
    } else if (status == 'rejected') {
      _isRejectProcessing = true;
    }
  });

  try {
    CollectionReference requestsCollection =
        FirebaseFirestore.instance.collection('requests');

    await requestsCollection.doc(requestId).update({'status': status});

    print('Request $requestId $status successfully');

    var updatedData = await requestsCollection.doc(requestId).get();

    if (status == 'approved') {
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: 'Business request approved ',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
      backgroundColor: AppColor.btnColor,
        textColor: Colors.black,
      );
    } else if (status == 'rejected') {
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: 'Business request rejected',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
     backgroundColor: AppColor.btnColor,
        textColor: Colors.black,
      );
    } else {
      // Handle other statuses if needed
    }
  } catch (error) {
    print('Error updating request status: $error');
    // Handle error as needed
  } finally {
    setState(() {
      if (status == 'approved') {
        _isApproveProcessing = false;
      } else if (status == 'rejected') {
        _isRejectProcessing = false;
      }
    });
  }
}
}