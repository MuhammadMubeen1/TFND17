import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:tfnd_app/themes/color.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
   final String emailAddress = 'support@femalenetwork.com';
  // Example privacy policy text
  final String privacyPolicyText = '''
 Introduction


The Female Network Mobile Application is committed to protecting your privacy. This privacy policy explains how we use and safeguard any information that you provide to us when you use the application.

Personal Information

When you use the Female Network Dubai Mobile Application, we may collect personal information such as your name, email address, and phone number. We may use this information to communicate with you about the features and benefits of the application.

Non-Personal Information

The Female Network Dubai Mobile Application may collect non-personal information such as your IP address, browser type, and operating system. We use this information to improve the quality and performance of the application and to ensure that it is providing a personalized user experience.

Secure Information

The Female Network Dubai Mobile Application is committed to safeguarding your information and uses a variety of security measures to protect your personal information from unauthorized access, use, and disclosure.

Disclosure of Information

The Female Network Dubai Mobile Application will not disclose any of your personal information to third parties unless required by law. We may, however, share non-personal information with third parties for the purposes of improving the performance of the application.

Cookies

The Female Network Dubai Mobile Application may use cookies to improve your user experience. These are text files that are placed on your device to remember user preferences and settings.

Camera

The Female Network Dubai Mobile Application will use the Camera of the device to scan QR code of the business to avail discounts.
Links to Other Websites


The Female Network Dubai Mobile Application may contain links to other websites. These are provided for your convenience, and we do not endorse or take responsibility for the content or privacy practices of these websites.

Changes to this Privacy Policy

The Female Network Dubai Mobile Application reserves the right to modify this privacy policy at any time without notice. You are encouraged to review this policy on a regular basis to ensure that you are aware of any changes.

Contact Us

Contact UsIf you have any questions or concerns about this privacy policy, please contact us at...
    ''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.bgColor,
        title:  const Center(child: Text('Privacy Policy', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),)),
          leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20,),
          onPressed: () {
            Navigator.of(context).pop(); // Navigate back to previous screen
          },
        ),
      
      ),
      body: Scaffold(
        body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black54, fontSize: 16.0),
                  children: <TextSpan>[
                    TextSpan(
                      text: privacyPolicyText,
                    ),
                    TextSpan(
                      text: emailAddress,
                      style: const  TextStyle(
                        color: Colors.blue, // Make the email address blue
                        decoration: TextDecoration.underline, // Underline the email address
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          launch('mailto:$emailAddress'); // Launch email app with pre-filled email address
                        },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        )
      )
      
    );
  }
}

