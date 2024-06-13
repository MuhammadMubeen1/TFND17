import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tfnd_app/Controllors/home_controllor.dart';
import 'package:tfnd_app/models/AddBusinessModel.dart';
import 'package:tfnd_app/models/AddEventModel.dart';
import 'package:tfnd_app/models/AddUserModel.dart';
import 'package:tfnd_app/screens/userSide/aEventDetail.dart';
import 'package:tfnd_app/screens/userSide/businessDetails.dart';
import 'package:tfnd_app/screens/userSide/profileBar.dart';
import 'package:tfnd_app/themes/color.dart';
import 'package:tfnd_app/widgets/reusable_text.dart';
import 'package:tfnd_app/widgets/status_update.dart';

class HomeBar extends StatefulWidget {
  String? curentuser;
  HomeBar({super.key, required this.curentuser});

  @override
  State<HomeBar> createState() => _homeBarState();
}

class _homeBarState extends State<HomeBar> {
  
  late HomeController _homeController;
  StreamSubscription<AddUserModel?>? _userDataSubscription;
  AddUserModel? userData;
  String? currentUserImage;

  @override
  void initState() {
    



    super.initState();
    _homeController = HomeController(widget.curentuser.toString());
    _homeController.checkUserRestrictionStatus(context);
    _userDataSubscription = _homeController.getUserDataStream().listen((user) {
      setState(() {
        userData = user;
      });
    });
    _fetchCurrentUserImage();
  }

  void _fetchCurrentUserImage() async {
    currentUserImage = await _homeController.getCurrentUserImage().toString();
    setState(() {});
  }

  @override
  void dispose() {
    _userDataSubscription?.cancel();
    super.dispose();
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColor.bgColor,
        appBar: AppBar(
          backgroundColor: AppColor.bgColor,
          toolbarHeight: 60,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: const Image(
            image: AssetImage("assets/images/tfndd.png"),
            height: 60,
          ),
          actions: const [
            SizedBox(
              width: 20,
            ),
          ],
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => profileBar(
                      currentUserEmail: widget.curentuser.toString(),
                    ),
                  ),
                );
              },
              child: CircleAvatar(
                backgroundImage: (userData != null &&
                        userData!.image != null &&
                        userData!.image!.isNotEmpty)
                    ? NetworkImage(userData!.image! as String)
                        as ImageProvider<Object>?
                    : const AssetImage("assets/images/tfndlog.jpg"),
              ),
            ),
          ),
        ),
        body: SafeArea(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [],
                  )
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              const Row(
                children: [
                  ReusableText(
                    title: "Events",
                    size: 16,
                    color: AppColor.darkTextColor,
                    weight: FontWeight.bold,
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                height: 210,
                child: StreamBuilder<List<AddEventModel>>(
                    stream: _homeController.getEvents(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      final List<AddEventModel>? events = snapshot.data;
                      if (events == null || events.isEmpty) {
                        return const Center(child: Text('No events available'));
                      }
                      return GridView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: events.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                               crossAxisCount: 1,
                      // childAspectRatio: 1.45,
                      mainAxisExtent: 320,
                      mainAxisSpacing: 30,
                        ),
                        itemBuilder: (context, index) {
                          final event = events[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (BuildContext context) =>
                                      EventsDetail(
                                    event: events[index],
                                    UserEmail: widget.curentuser.toString(),
                                  ),
                                ),
                              );
                            },
                            child: Stack(
                              children: [
                                events[index].image == null
                                    ? Container(
                                        height: 180,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            image: const DecorationImage(
                                                image: NetworkImage(
                                                    "https://d2x3xhvgiqkx42.cloudfront.net/12345678-1234-1234-1234-1234567890ab/651c25b0-2d60-43c8-addf-1df2fd575568/2021/08/16/455d8bde-5940-4005-a79a-56005926c158/65b4998a-5202-4a77-af1e-c646f5fc36e1.png"),
                                                fit: BoxFit.cover)),
                                      )
                                    : Container(
                                        height: 180,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            image: DecorationImage(
                                                image: NetworkImage(
                                                    events[index]
                                                        .image
                                                        .toString()),
                                                fit: BoxFit.cover)),
                                      ),
                                Positioned(
                                   top: 140,
                                  left: 20,
                                  right: 20,
                                    child: Container(
                                      height: 70,
                                      width: 310,
                                      decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 18),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                ReusableText(
                                                  title: events[index].name,
                                                  color: AppColor.blackColor,
                                                  weight: FontWeight.bold,
                                                ),
                                                const SizedBox(
                                                  height: 1,
                                                ),
                                                ReusableText(
                                                  title: events[index]
                                                              .Location!
                                                              .length >
                                                          20
                                                      ? events[index]
                                                              .Location!
                                                              .substring(
                                                                  0, 20) +
                                                          '...'
                                                      : events[index].Location,
                                                  color: AppColor.hintColor,
                                                  size: 9,
                                                  weight: FontWeight.bold,
                                                ),
                                                const SizedBox(
                                                  height: 3,
                                                ),
                                                ReusableText(
                                                  title: events[index].date,
                                                  color: AppColor.textColor,
                                                  size: 10,
                                                  weight: FontWeight.bold,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 10),
                                            child: Row(
                                              children: [
                                                ReusableText(
                                                  title: events[index].price,
                                                  color: AppColor.btnColor,
                                                  weight: FontWeight.bold,
                                                  size: 12,
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                const ReusableText(
                                                  title: "\AED",
                                                  color: AppColor.btnColor,
                                                  weight: FontWeight.bold,
                                                  size: 14,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ))
                              ],
                            ),
                          );
                        },
                      );
                    }),
              ),
              const SizedBox(
                height: 20,
              ),
              const Row(
                children: [
                  ReusableText(
                    title: "Popular Businesses",
                    color: AppColor.darkTextColor,
                    weight: FontWeight.bold,
                    size: 16,
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                height: 80 ,
                child: StreamBuilder<List<AddBusinessModel>>(
                  stream: _homeController.getMostClickableBusinesses(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    final List<AddBusinessModel>? businesses = snapshot.data;
                    if (businesses == null || businesses.isEmpty) {
                      return const Center(
                          child: Text('No businesses available'));
                    }
                    return GridView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: businesses.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        mainAxisExtent: 90,
                      
                      ),
                      itemBuilder: (context, index) {
                        final business = businesses[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (BuildContext context) => businessDets(
                                  business: business,
                                  emaildetails: widget.curentuser.toString(),
                                  cureeemails: widget.curentuser.toString(),
                                ),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              business.image == null || business.image!.isEmpty
                                  ? const CircleAvatar(
                                      backgroundImage: AssetImage(
                                          "assets/images/tfndlog.jpg"),
                                      radius: 35,
                                    )
                                  : CircleAvatar(
                                      backgroundImage:
                                          NetworkImage(business.image!),
                                      radius: 35,
                                    ),
                              const SizedBox(width: 20),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              const Row(
                children: [
                  ReusableText(
                    title: "Latest Businesses",
                    color: AppColor.darkTextColor,
                    weight: FontWeight.bold,
                    size: 16,
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                height: 210,
                child: StreamBuilder<List<AddBusinessModel>>(
                  stream: _homeController.getBusinessesOnce(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    final List<AddBusinessModel>? businesses = snapshot.data;
                    if (businesses == null || businesses.isEmpty) {
                      return const Center(
                          child: Text('No businesses available'));
                    }
                    return GridView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: businesses.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        mainAxisExtent: 140,
                        crossAxisSpacing: 0,
                        mainAxisSpacing: 0,
                      ),
                      itemBuilder: (context, index) {
                        final business = businesses[index];
                        return Padding(
                            padding: const EdgeInsets.only(
                                right: 12.0), // Add spacing here
                            child: GestureDetector(
                              onTap: () {
                                updateClickCount(
                                    businesses[index].uid.toString());
                                Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (BuildContext context) =>
                                        businessDets(
                                      business: businesses[index],
                                      emaildetails:
                                          widget.curentuser.toString(),
                                      cureeemails: widget.curentuser.toString(),
                                    ),
                                  ),
                                );
                              },
                              child: Column(
                                children: [
                                  businesses[index].image == null ||
                                          businesses[index].image!.isEmpty ||
                                          businesses[index].image == ""
                                      ? Container(
                                          height: 130,
                                          width: 130,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              image: const DecorationImage(
                                                  image: AssetImage(
                                                      "assets/images/tfndlog.jpg"),
                                                  fit: BoxFit.cover)),
                                        )
                                      : Container(
                                          height: 130,
                                          width: 130,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              image: DecorationImage(
                                                  image: NetworkImage(
                                                      businesses[index]
                                                          .image
                                                          .toString()),
                                                  fit: BoxFit.cover)),
                                        ),
                                  const SizedBox(
                                    height: 7,
                                  ),
                                  ReusableText(
                                    title: businesses[index].name,
                                    color: AppColor.darkTextColor,
                                    size: 12,
                                    weight: FontWeight.bold,
                                  ),
                                  const SizedBox(
                                    height: 2,
                                  ),
                                  ReusableText(
                                    title: businesses[index].category,
                                    color: AppColor.hintColor,
                                    size: 10,
                                    weight: FontWeight.bold,
                                  ),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const ReusableText(
                                        title: "Up to ",
                                        color: AppColor.blackColor,
                                        size: 12.5,
                                        weight: FontWeight.bold,
                                      ),
                                      ReusableText(
                                        title: businesses[index].discount,
                                        color: AppColor.blackColor,
                                        size: 12.5,
                                        weight: FontWeight.bold,
                                      ),
                                      const ReusableText(
                                        title: "% OFF",
                                        color: AppColor.blackColor,
                                        size: 12.5,
                                        weight: FontWeight.bold,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ));
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: 10),
            ]),
          ),
        )));
  }

  void updateClickCount(String businessId) async {
    try {
      final businessRef = FirebaseFirestore.instance
          .collection("BusinessRegister")
          .doc(businessId);
      final doc = await businessRef.get();

      if (doc.exists) {
        final currentClickCount = doc.data()?['clickCount'] ?? 0;
        await businessRef.update({'clickCount': currentClickCount + 1});
        print('Click count updated successfully.');
      } else {
        print('Business document with ID $businessId does not exist.');
      }
    } catch (e) {
      print('Error updating click count: $e');
    }
  }
}
