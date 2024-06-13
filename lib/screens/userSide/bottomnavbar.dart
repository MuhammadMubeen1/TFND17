import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tfnd_app/screens/userSide/businessBar.dart';
import 'package:tfnd_app/screens/userSide/chat_screen.dart';
import 'package:tfnd_app/screens/userSide/eventsBar.dart';
import 'package:tfnd_app/screens/userSide/homeBar.dart';
import 'package:tfnd_app/screens/userSide/profileBar.dart';
import 'package:tfnd_app/screens/userSide/scanner.dart';
import 'package:tfnd_app/themes/color.dart';

class BottomNavBar extends StatefulWidget {
  String userEmail, status;

  BottomNavBar({Key? key, required this.userEmail, required this.status})
      : super(key: key);
  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _currentIndex = 0;
  List<Widget>? _pages;
  String? isPaid;

  // Initialize Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  @override
  void initState() {
    super.initState();

    _pages = [
      HomeBar(curentuser: widget.userEmail),
      BusinessBar(cureeemils: widget.userEmail,),
      Scanner(widget.userEmail),
      eventsBar(
        useremail: widget.userEmail,
      ),
      Chat(userEmail: widget.userEmail),
      profileBar(
        currentUserEmail: widget.userEmail,
      ),
    ];

    print("current email == = ${widget.userEmail}");
    print(widget.status);
  }

  @override
  void dispose() {
    isPaid;
    // TODO: implement dispose

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        bottomNavigationBar: SizedBox(
          height: 80,
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            iconSize: 22,
            selectedItemColor: AppColor.primaryColor,
            unselectedItemColor: AppColor.textColor,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                backgroundColor: Colors.white,
                icon: ImageIcon(
                  AssetImage('assets/icons/home.png'),
                ),
                label: "Home",
              ),
              BottomNavigationBarItem(
                backgroundColor: Colors.white,
                icon: ImageIcon(
                  AssetImage('assets/icons/business.png'),
                ),
                label: "Business",
              ),
              BottomNavigationBarItem(
                backgroundColor: Colors.white,
                icon: Icon(Icons.document_scanner_outlined),
                label: "Discounts",
              ),
              BottomNavigationBarItem(
                backgroundColor: Colors.white,
                icon: ImageIcon(
                  AssetImage('assets/icons/event.png'),
                ),
                label: "Events",
              ),
              BottomNavigationBarItem(
                backgroundColor: Colors.white,
                icon: Icon(
                  Icons.post_add_rounded,
                  size: 26,
                ), // Using the message icon from Material Icons
                label: "Posts",
              ),
              BottomNavigationBarItem(
                backgroundColor: Colors.white,
                icon: ImageIcon(
                  AssetImage('assets/icons/profile.png'),
                ),
                label: "Profile",
              ),
            ],
            selectedFontSize: 10,
            unselectedFontSize: 10,
            selectedLabelStyle:
                const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            unselectedLabelStyle: const TextStyle(
              fontSize: 10,
            ),
          ),
        ),
        body: _pages?[_currentIndex],
      ),
    );
  }
}
