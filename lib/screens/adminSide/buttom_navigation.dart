import 'package:flutter/material.dart';
import 'package:tfnd_app/screens/adminSide/aEventsBar.dart';
import 'package:tfnd_app/screens/adminSide/aUsers.dart';
import 'package:tfnd_app/screens/adminSide/businessRequests.dart';
import 'package:tfnd_app/screens/adminSide/profile.dart';
import 'package:tfnd_app/screens/userSide/business_catagory.dart';
import 'package:tfnd_app/themes/color.dart';

class Buttomnavigation extends StatefulWidget {
  final String adminemail;

  Buttomnavigation({
    super.key,
    required this.adminemail,
  });

  @override
  State<Buttomnavigation> createState() => _ButtomnavigationState();
}

class _ButtomnavigationState extends State<Buttomnavigation> {
  int _currentIndex = 0;
  List<Widget>? _pages;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("admin emails ${widget.adminemail}");

    _pages = [
      BusinessRequests(
        mub: widget.adminemail,
      ),
      const aEventsBar(),
      CategoryScreen(),
      const aUsers(),  
      Profile(
        currentuser: widget.adminemail,
   
      ),
    ];
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
          iconSize: 25,
          selectedItemColor: AppColor.primaryColor,
          unselectedItemColor: AppColor.textColor,
          onTap: (v) {
            setState(() {
              _currentIndex = v;
            });
          },
          items: const [
            BottomNavigationBarItem(
              backgroundColor: Colors.white,
              icon: ImageIcon(
                AssetImage('assets/icons/business.png'),
              ),
              label: "Business",
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
              icon: Icon(Icons.category), // Use the desired category icon
              label: "Categories",
            ),
            BottomNavigationBarItem(
              backgroundColor: Colors.white,
              icon: Icon(
                Icons.person_add,
                // You can adjust the color as needed
              ),
              label: "Users",
            ),
            BottomNavigationBarItem(
              backgroundColor: Colors.white,
              icon: Icon(
                Icons.person,
                // You can adjust the color as needed
              ),
              label: "Profile",
            ),
          ],
          selectedFontSize: 16,
          unselectedFontSize: 14,
          selectedLabelStyle:
              const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(
            fontSize: 11,
          ),
        ),
      ),
      body: _pages?[_currentIndex],
    ));
  }
}
