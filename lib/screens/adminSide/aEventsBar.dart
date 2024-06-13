import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tfnd_app/screens/adminSide/aAddEvent.dart';
import 'package:tfnd_app/screens/adminSide/event_details.dart';
import 'package:tfnd_app/models/AddEventModel.dart';
import 'package:tfnd_app/themes/color.dart';
import 'package:tfnd_app/widgets/reusable_text.dart';

class aEventsBar extends StatefulWidget {
  const aEventsBar({super.key});

  @override
  State<aEventsBar> createState() => _aEventsBarState();
}

class _aEventsBarState extends State<aEventsBar> {
  @override
  List<AddEventModel> events = [];
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.bgColor,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const ReusableText(
          title: "Events",
          color: AppColor.blackColor,
          size: 20,
          weight: FontWeight.w500,
        ),
        actions: [
               IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EventSearchScreen(
                          events: events,
                        )),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                Container(
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(10)),
                  height: 55,
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColor.primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) => const aAddEvent(),
                        ),
                      );
                    },
                    child: const Center(
                      child: ReusableText(
                        title: "Add New Event",
                        color: AppColor.blackColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("adminevents")
                      .orderBy(FieldPath.documentId,
                          descending:
                              true) // Order events by document ID in descending order
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }

                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text('No events available.'),
                      );
                    }

                    events = snapshot.data!.docs
                        .map((doc) => AddEventModel.fromJson(
                            doc.data() as Map<String, dynamic>))
                        .toList();

                    return Column(
                      children: events.asMap().entries.map((entry) {
                        int index = entry.key;
                        AddEventModel event = entry.value;

                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (BuildContext context) =>
                                        eventsDetailss(
                                      event: event,
                                      UserEmail: '',
                                      onDeleteSuccess: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ),
                                );
                              },
                              child: Stack(
                                children: [
                                  Container(
                                    height: 180,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      image: event.image == null
                                          ? const DecorationImage(
                                              image: NetworkImage(
                                                "https://d2x3xhvgiqkx42.cloudfront.net/12345678-1234-1234-1234-1234567890ab/651c25b0-2d60-43c8-addf-1df2fd575568/2021/08/16/455d8bde-5940-4005-a79a-56005926c158/65b4998a-5202-4a77-af1e-c646f5fc36e1.png",
                                              ),
                                              fit: BoxFit.cover,
                                            )
                                          : DecorationImage(
                                              image: NetworkImage(
                                                event.image.toString(),
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 118,
                                    left: 20,
                                    right: 20,
                                    child: Container(
                                      height: 70,
                                      width: 310,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 25),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                ReusableText(
                                                  title: event.name,
                                                  color: AppColor.blackColor,
                                                  weight: FontWeight.bold,
                                                ),
                                                const SizedBox(
                                                  height: 1,
                                                ),
                                                ReusableText(
                                                  title: event.Location!
                                                              .length >
                                                          25
                                                      ? '${event.Location!.substring(0, 25)}...' // Limit to 20 characters
                                                      : event.Location,
                                                  color: AppColor.hintColor,
                                                  size: 8,
                                                  weight: FontWeight.bold,
                                                ),
                                                const SizedBox(
                                                  height: 3,
                                                ),
                                                ReusableText(
                                                  title: event.date,
                                                  color: AppColor.textColor,
                                                  size: 9.5,
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
                                                  title: event.price,
                                                  color: AppColor.btnColor,
                                                  weight: FontWeight.bold,
                                                  size: 14,
                                                ),
                                               const  SizedBox(width: 5,),
                                                const ReusableText(
                                                  title: "AED",
                                                  color: AppColor.btnColor,
                                                  weight: FontWeight.bold,
                                                  size: 12,
                                                ),
                                               
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                                height: 30), // Adjust the spacing as needed
                          ],
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(
                  height: 20,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EventSearchScreen extends StatefulWidget {
  List<AddEventModel> events = [];

  EventSearchScreen({Key? key, required this.events}) : super(key: key);

  @override
  _EventSearchScreenState createState() => _EventSearchScreenState();
}

class _EventSearchScreenState extends State<EventSearchScreen> {
  TextEditingController searchController = TextEditingController();
  List<AddEventModel> filteredBusinesses = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchController,
          onChanged: (value) {
            setState(() {
              filteredBusinesses = widget.events
                  .where((business) => business.name!
                      .toLowerCase()
                      .contains(value.toLowerCase()))
                  .toList();
            });
          },
          decoration: const InputDecoration(
            hintText: 'Search event by name ',
            border: InputBorder.none,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        itemCount: filteredBusinesses.length,
        itemBuilder: (context, index) {
          final business = filteredBusinesses[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => eventsDetailss(
                    event: filteredBusinesses[index],
                    UserEmail: '',
                    onDeleteSuccess: () {},
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Stack(
                children: [
                  business.image == null
                      ? Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              image: const DecorationImage(
                                  image: NetworkImage(
                                      "https://d2x3xhvgiqkx42.cloudfront.net/12345678-1234-1234-1234-1234567890ab/651c25b0-2d60-43c8-addf-1df2fd575568/2021/08/16/455d8bde-5940-4005-a79a-56005926c158/65b4998a-5202-4a77-af1e-c646f5fc36e1.png"),
                                  fit: BoxFit.cover)),
                        )
                      : Container(
                          height: 190,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              image: DecorationImage(
                                  image:
                                      NetworkImage(business.image.toString()),
                                  fit: BoxFit.cover)),
                        ),
                  Positioned(
                      top: 120,
                      left: 20,
                      right: 20,
                      child: Container(
                        height: 70,
                        width: 310,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(15)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ReusableText(
                                    title: business.name,
                                    color: AppColor.blackColor,
                                    weight: FontWeight.bold,
                                    size: 13,
                                  ),
                                  const SizedBox(
                                    height: 1,
                                  ),
                                  ReusableText(
                                    title: business.Location!.length > 25
                                        ? '${business.Location!.substring(0, 25)}...' // Limit to 20 characters
                                        : business.Location,
                                    color: AppColor.hintColor,
                                    size: 8,
                                    weight: FontWeight.bold,
                                  ),
                                  const SizedBox(
                                    height: 3,
                                  ),
                                  ReusableText(
                                    title: business.date,
                                    color: AppColor.textColor,
                                    size: 10.5,
                                    weight: FontWeight.bold,
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 18),
                              child: Row(
                                children: [
                                  const ReusableText(
                                    title: "\$",
                                    color: AppColor.pinktextColor,
                                    weight: FontWeight.bold,
                                    size: 16,
                                  ),
                                  ReusableText(
                                    title: business.price,
                                    color: AppColor.pinktextColor,
                                    weight: FontWeight.bold,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ))
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
