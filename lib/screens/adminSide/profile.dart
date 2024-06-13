import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tfnd_app/screens/adminSide/basic_subcription.dart';
import 'package:tfnd_app/screens/adminSide/basic_subscriptioninfo.dart';
import 'package:tfnd_app/screens/adminSide/discountinfo.dart';
import 'package:tfnd_app/screens/adminSide/editbusiness_profile.dart';
import 'package:tfnd_app/screens/adminSide/eventbookin_info.dart';
import 'package:tfnd_app/models/AddUserModel.dart';
import 'package:tfnd_app/screens/auth/signin.dart';
import 'package:tfnd_app/themes/color.dart';
import 'package:tfnd_app/widgets/reusable_outlined_button.dart';
import 'package:tfnd_app/widgets/reusable_text.dart';

class Profile extends StatefulWidget {
  String currentuser;
 

  Profile({super.key, required this.currentuser, });

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  @override
    Stream<QuerySnapshot>? _paymentStream;
  void initState() {

    // TODO: implement initState
    super.initState();
    print('admin user 2........${widget.currentuser}');

_getAdminData();

  }

  bool _passwordVisible = false;
    List<DocumentSnapshot> _filteredPaymentDocs = [];
  var userData;
  Future<Map<String, dynamic>?>? userDataFuture;
  Future<Map<String, dynamic>?> getUserData(String currentUserEmail) async {
    try {
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('Admin')
          .where('email', isEqualTo: currentUserEmail)
          .get();

      // Check if any documents match the query
      if (userSnapshot.docs.isNotEmpty) {
        // Extract data from the first document
        userData = userSnapshot.docs.first.data();

        // Return the user data as a map
        return userData as Map<String, dynamic>;
      } else {
        // No matching document found
        return null;
      }
    } catch (e) {
      // Handle any errors
      print("Error fetching user data: $e");
      return null;
    }
  }

Future<void> _getAdminData() async {
  try {
    // Listen for changes to the document
    FirebaseFirestore.instance
        .collection('Admin')
        .where('email', isEqualTo: widget.currentuser)
        .snapshots()
        .listen((adminSnapshot) {
      if (adminSnapshot.docs.isNotEmpty) {
        // Assuming there's only one document matching the email
        setState(() {
          // Update the adminData variable with the fetched data
          userData= adminSnapshot.docs.first.data();
        });
      } else {
        // Handle the case where no admin data is found
        setState(() {
          userData = null; // Clear adminData if no data is found
        });
      }
    });
  } catch (e) {
    print('Error fetching admin data: $e');
  }
}


  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: AppColor.bgColor,
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(
                        'TFND USER INFORMATION ',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height:10,),
                 CircleAvatar(
                            backgroundImage: 
                                 const AssetImage("assets/images/tfndlog.jpg"),
                            radius: 45,    
                          ),
                  ],
                ),
            
              ),

             
              // ListTile(
              //   title: const Text('Event Booking Info'),
              //   onTap: () {
              //     // Navigate to Screen 1
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(builder: (context) => PaymentScreen()),
              //     ); // Close the drawer
              //     // Add your navigation logic here
              //   },
              // ),

               ListTile(
                title: Text('Subscription info'),
                onTap: () {
                  // Navigate to Screen 2
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BasicDiscountinfo()),
                  ); // C// Close the drawer
                  // Add your navigation logic here
                },
              ),
                ListTile(
                title:const  Text('Subscription Amount'),
                onTap: () {
                  // Navigate to Screen 2
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>  Payment()),
                  );
                  
                },
              ) ,
 ListTile(
                title: Text('Discounts Availed Info'),
                onTap: () {
                  // Navigate to Screen 2
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Discountinfo()),
                  ); // C// Close the drawer
                  // Add your navigation logic here
                },
              ),

            ],
          ),
        ),
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.menu), // Add the menu icon here
            onPressed: () {
              _scaffoldKey.currentState
                  ?.openDrawer(); // Open the drawer when the menu icon is tapped
            },
          ),
          backgroundColor: AppColor.bgColor,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: const ReusableText(
            title: "Profile",
            color: AppColor.blackColor,
            size: 20,
            weight: FontWeight.w500,
          ),
          actions: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => Editbusinessprofile(
                      image: userData!['image'].toString(),
                      password: userData!['password'].toString(),
                      eamil: userData!['email'].toString(),
                    ),
                  ),
                );
              },
              child: const ImageIcon(AssetImage("assets/icons/edit.png")),
            ),
            const SizedBox(
              width: 20,
            )
          ],
        ),
        body:userData!=null? SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child:  Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 15,
                          ),
                          CircleAvatar(
                            backgroundImage: (userData['image'] != null &&
                                    userData['image']!.isNotEmpty)
                                ? NetworkImage(userData['image'] as String)
                                    as ImageProvider<Object>?
                                : const AssetImage("assets/images/tfndlog.jpg"),
                            radius: 70,
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                        

                          TextFormField(
                            // Negate the visibility here
                            readOnly: true,
                            decoration: InputDecoration(
                              hintText: "${userData!['email'] ?? 'N/A'}",
                              prefixIcon: const Icon(
                                Icons.email_outlined,
                                color: AppColor.hintColor,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18.0),
                                borderSide:
                                    const BorderSide(color: Colors.white),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18.0),
                                borderSide:
                                    const BorderSide(color: Colors.white),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18.0),
                                borderSide:
                                    const BorderSide(color: Colors.white),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18.0),
                                borderSide:
                                    const BorderSide(color: Colors.white),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),

                          const SizedBox(
                            height: 20,
                          ),

                          TextFormField(
                            readOnly: true,
                            obscureText:
                                !_passwordVisible, // Negate the visibility here
                            initialValue: "${userData!['password'] ?? 'N/A'}",
                            decoration: InputDecoration(
                              hintText: "${userData!['password'] ?? 'N/A'}",
                              prefixIcon: const Icon(
                                Icons.password_rounded,
                                color: AppColor.btnColor,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _passwordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: AppColor.btnColor,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _passwordVisible = !_passwordVisible;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18.0),
                                borderSide:
                                    const BorderSide(color: Colors.white),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18.0),
                                borderSide:
                                    const BorderSide(color: Colors.white),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18.0),
                                borderSide:
                                    const BorderSide(color: Colors.white),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18.0),
                                borderSide:
                                    const BorderSide(color: Colors.white),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),

                          // ),
                          const SizedBox(
                            height: 20,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          ReusableOutlinedButton(
                            title: "Log Out",
                            onTap: () async {
                              try {
                            logout(context);
                              } catch (e) {
                                print("Error signing out: $e");
                    
                              }
                            },
                          )
                        ],
              )))) :const Center(
            child: CircularProgressIndicator(), // Show loading indicator while fetching data
          ),
              
               );
                }  
                Future<void> logout(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  
  // Clear all preferences
  await prefs.clear();
  
  // Sign out from Firebase
  await FirebaseAuth.instance.signOut();
  
  // Navigate to the sign-in screen
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => signin(email2: '',)),
    (Route<dynamic> route) => false,
  );
                }
      
}