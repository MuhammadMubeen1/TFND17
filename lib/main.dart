
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:tfnd_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tfnd_app/widgets/apple_screen.dart';
import 'package:tfnd_app/widgets/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tfnd_app/themes/color.dart';
import 'package:workmanager/workmanager.dart';


void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();   
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

   FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );  
  
  Stripe.publishableKey =
      "pk_test_51OKN7TDJfrTnX036CkGLZXePmMzmIACoy5InrlA9RUDchrOoUu84IaAr7Q5lIP4wnCl5wUkBqRCvol1Q7M6YnlQP00p0l40ol1";
WidgetsFlutterBinding.ensureInitialized();

 
  runApp(MyApp());
}


class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}
class _MyAppState extends State<MyApp> {
  String? curentmail;
  @override
  

  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TFND',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColor.bgColor,
        fontFamily: 'Montserrat',
      ),
       home: 
       
    SplashBody(email3: curentmail,),
 );
  }
Future<String?> getCurrentUserEmail() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('email');
}

  Future<bool> checkLoginStatus() async {
    // Check the user login status using SharedPreferences or any other method
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    curentmail = prefs.getString('email');

    return isLoggedIn;
  }
}
