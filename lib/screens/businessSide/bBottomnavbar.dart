import 'package:flutter/material.dart';
import 'package:tfnd_app/models/AddUserModel.dart';
import 'package:tfnd_app/screens/businessSide/bBusinessBar.dart';
import 'package:tfnd_app/screens/businessSide/bProfileBar.dart';
import 'package:tfnd_app/themes/color.dart';

class Bottomnavbar extends StatefulWidget {
  String? currentuser;
  final AddUserModel? userData;
  Bottomnavbar({Key? key, required this.currentuser, required this.userData})
      : super(
          key: key,
        );

  @override
  State<Bottomnavbar> createState() => _BottomnavbarState();
}

class _BottomnavbarState extends State<Bottomnavbar> {
  int _currentIndex = 0;
  late List _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      BusinessBar(
        emailuser: widget.currentuser.toString(),
      ),
      ProfileBar(
        currentuser: widget.currentuser.toString(),
        userdat: widget.userData,
      )
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
                label: "Businesses",
              ),
              BottomNavigationBarItem(
                backgroundColor: Colors.white,
                icon: ImageIcon(
                  AssetImage('assets/icons/profile.png'),
                ),
                label: "Profile",
              ),
            ],
            selectedFontSize: 16,
            unselectedFontSize: 14,
            selectedLabelStyle:
              const  TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            unselectedLabelStyle: const TextStyle(
              fontSize: 11,
            ),
          ),
        ),
        body: _pages[_currentIndex],
      ),
    );
  }
}
