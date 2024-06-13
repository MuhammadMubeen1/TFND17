

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:tfnd_app/Controllors/scanner_controllor.dart';
import 'package:tfnd_app/models/AddUserModel.dart';
import 'package:tfnd_app/screens/subscription.dart';


import 'package:tfnd_app/themes/color.dart';
import 'package:tfnd_app/widgets/reusable_text.dart';
import 'package:tfnd_app/widgets/status_update.dart';

class Scanner extends StatefulWidget {
  Scanner(this.email, {Key? key}) : super(key: key);
  final String email;

  @override
  _ScannerState createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  final ScannerController _controller = ScannerController();
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  AddUserModel? userData;
  String? isPaid;
  List<String> scannedCodes = [];
  bool _isSubscribing = false;
  bool isLoading = false;
  bool isDialogOpen = false;
  final SubscriptionService _subscriptionService = SubscriptionService();
  @override
  void initState() {
    super.initState();
    _initializeScanner();
    
    _controller.checkAndUpdateSubscriptionStatus();
    _controller.listenToUserData(widget.email, (data) {
      setState(() {
        userData = data;
        if (userData != null) {
          isPaid = userData!.subscription;
        }
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<void> _initializeScanner() async {
    try {
      if (userData != null) {
        print("Subscription status: $isPaid");
      }
    } catch (e) {
      print("Error initializing scanner: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.bgColor,
        toolbarHeight: 60,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title:const  ReusableText(
          title: "Discounts",
          color: AppColor.blackColor,
          size: 20,
          weight: FontWeight.w500,
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isPaid == null) {
      return Center(
        child: CircularProgressIndicator(color: AppColor.blackColor),
      );
    } else if (isPaid == "paid") {
      return _buildPaidSubscriptionView();
    } else {
      return _buildUnpaidSubscriptionView();
    }
  }

  Widget _buildPaidSubscriptionView() {
    return Column(
      children: <Widget>[
      const  Text(
          "Please Scan QR Code of the\nstore to avail discount.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: AppColor.btnColor,
            fontWeight: FontWeight.w400,
          ),
        ),
      const   SizedBox(
          height: 20,
        ),
        Expanded(
          flex: 4,
          child: _buildQrView(context),
        ),
       const  SizedBox(height: 20),
      ],
    );
  }

  Widget _buildUnpaidSubscriptionView() {
    return Center(
      child: Container(
        width: 310,
        height: 450,
        decoration: BoxDecoration(
          color: AppColor.btnColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow:const  [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(4, 4),
              blurRadius: 10,
              spreadRadius: 1,
            ),
            BoxShadow(
              color: Colors.white,
              offset: Offset(-4, -4),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
          gradient:const  LinearGradient(
            colors: [AppColor.bgColor, AppColor.bgColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
          const   Padding(
              padding: EdgeInsets.only(top: 30),
              child: Image(
                height: 140,
                image: AssetImage("assets/images/tfndd.png"),
              ),
            ),
           const  SizedBox(height: 20),
           const  Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.0),
              child: Text(
                "Unlock exclusive savings on our premium products! Enjoy top-notch quality at unbeatable prices. Grab your discount now and enhance your experience!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColor.textColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            SizedBox(height: 75),
            Center(
              child: GestureDetector(
                onTap: () async {
                  if (!_isSubscribing) {
                    setState(() {
                      _isSubscribing = true;
                    });
                    await _subscriptionService
                                      .showSubscriptionPopup(
                                          context, widget.email.toString());
                    setState(() {
                      _isSubscribing = false;
                    });
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
                        color: Colors.white.withOpacity(0.5),
                        offset: Offset(0, 3),
                        blurRadius: 6,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      "Get Discounts Now!",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 300.0
        : 300.0;

    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Colors.red,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: scanArea,
      ),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  Future<void> _onQRViewCreated(QRViewController controller) async {
    controller.scannedDataStream.listen((scanData) async {
      if (!scannedCodes.contains(scanData.code)) {
        scannedCodes.add(scanData.code.toString());
        List<String> qrParts = scanData.code!.split('|');
        String businessName = qrParts[1];
        String discount = qrParts[0];
        String businessId = qrParts[3];

        bool canScan =
            await _controller.canScanQR(businessId, widget.email);

        if (canScan) {
          await _controller.showDialogForScannedQR(
              context, scanData, () => setState(() {
                    isDialogOpen = false;
                  }));
          await _controller.saveBusinessDetailsToFirestore(
              businessName, discount, userData!, businessId);
          await _controller.recordScan(businessId, widget.email);
        } else {
          final snackBar = SnackBar(
            content: Text(
                'You have availed the maximum number of 3 discounts from this business in the current month of your subscription.'),
            duration: Duration(seconds: 6),
            backgroundColor: Colors.black,
            behavior: SnackBarBehavior.floating,
          );

          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      } else {
        print('QR code already scanned in this session.');
      }
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    debugPrint('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No permission to access the camera'),
        ),
      );
    }
  }
}
