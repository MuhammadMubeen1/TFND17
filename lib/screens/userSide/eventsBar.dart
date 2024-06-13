import 'package:flutter/material.dart';
import 'package:tfnd_app/Controllors/event_controlor.dart';
import 'package:tfnd_app/models/AddEventModel.dart';
import 'package:tfnd_app/screens/userSide/aEventDetail.dart';
import 'package:tfnd_app/themes/color.dart';
import 'package:tfnd_app/widgets/reusable_text.dart';
import 'package:tfnd_app/widgets/status_update.dart';


class eventsBar extends StatefulWidget {
  final String? useremail;
  eventsBar({Key? key, required this.useremail}) : super(key: key);

  @override
  State<eventsBar> createState() => _EventsBarState();
}

class _EventsBarState extends State<eventsBar> {
  TextEditingController searchController = TextEditingController();
  late Future<List<AddEventModel>> eventsFuture;

  @override
  void initState() {

    super.initState();
    eventsFuture = EventService().fetchEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.bgColor,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const ReusableText(
          title: "Events at TFND",
          color: AppColor.blackColor,
          size: 20,
          weight: FontWeight.w500,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventSearchScreen(
                    eventsFuture: eventsFuture,
                    email: widget.useremail.toString(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<AddEventModel>>(
        future: eventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.black,));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No events found'));
          } else {
            List<AddEventModel> events = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                children: [
                  Expanded(
                    child: GridView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemCount: events.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        mainAxisExtent: 250,
                        mainAxisSpacing: 0,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        if (events[index].name!.toLowerCase().contains(searchController.text.toLowerCase())) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (BuildContext context) => EventsDetail(
                                    event: events[index],
                                    UserEmail: widget.useremail.toString(),
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
                                          borderRadius: BorderRadius.circular(15),
                                          image: const DecorationImage(
                                            image: NetworkImage("https://d2x3xhvgiqkx42.cloudfront.net/12345678-1234-1234-1234-1234567890ab/651c25b0-2d60-43c8-addf-1df2fd575568/2021/08/16/455d8bde-5940-4005-a79a-56005926c158/65b4998a-5202-4a77-af1e-c646f5fc36e1.png"),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      )
                                    : Container(
                                        height: 180,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(15),
                                          image: DecorationImage(
                                            image: NetworkImage(events[index].image.toString()),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
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
                                      borderRadius: BorderRadius.circular(15),
                                    ),
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
                                                title: events[index].name,
                                                color: AppColor.blackColor,
                                                weight: FontWeight.bold,
                                                size: 13,
                                              ),
                                              const SizedBox(height: 1),
                                              ReusableText(
                                                title: events[index].Location!.length > 25
                                                    ? '${events[index].Location!.substring(0, 25)}...'
                                                    : events[index].Location,
                                                color: AppColor.hintColor,
                                                size: 8,
                                                weight: FontWeight.bold,
                                              ),
                                              const SizedBox(height: 3),
                                              ReusableText(
                                                title: events[index].date,
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
                                              ReusableText(
                                                title: events[index].price,
                                                color: AppColor.btnColor,
                                                weight: FontWeight.bold,
                                                size: 16,
                                              ),
                                              const ReusableText(
                                                title: "\AED ",
                                                color: AppColor.btnColor,
                                                weight: FontWeight.bold,
                                                size: 16,
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
                          );
                        } else {
                          return Container();
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

class EventSearchScreen extends StatefulWidget {
  final Future<List<AddEventModel>> eventsFuture;
  final String email;

  EventSearchScreen({Key? key, required this.eventsFuture, required this.email}) : super(key: key);

  @override
  _EventSearchScreenState createState() => _EventSearchScreenState();
}

class _EventSearchScreenState extends State<EventSearchScreen> {
  TextEditingController searchController = TextEditingController();
  List<AddEventModel> filteredEvents = [];
  final FocusNode searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(searchFocusNode);
    });

    widget.eventsFuture.then((events) {
      setState(() {
        filteredEvents = events;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          focusNode: searchFocusNode,
          controller: searchController,
          onChanged: (value) {
            setState(() {
              filteredEvents = filteredEvents
                  .where((event) => event.name!.toLowerCase().contains(value.toLowerCase()))
                  .toList();
            });
          },
          decoration: const InputDecoration(
            hintText: 'Search event by name',
            border: InputBorder.none,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        itemCount: filteredEvents.length,
        itemBuilder: (context, index) {
          final event = filteredEvents[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => EventsDetail(
                    event: event,
                    UserEmail: widget.email,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Stack(
                children: [
                  event.image == null
                      ? Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            image: const DecorationImage(
                              image: NetworkImage("https://d2x3xhvgiqkx42.cloudfront.net/12345678-1234-1234-1234-1234567890ab/651c25b0-2d60-43c8-addf-1df2fd575568/2021/08/16/455d8bde-5940-4005-a79a-56005926c158/65b4998a-5202-4a77-af1e-c646f5fc36e1.png"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : Container(
                          height: 190,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            image: DecorationImage(
                              image: NetworkImage(event.image.toString()),
                              fit: BoxFit.cover,
                            ),
                          ),
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
                        borderRadius: BorderRadius.circular(15),
                      ),
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
                                  title: event.name,
                                  color: AppColor.blackColor,
                                  weight: FontWeight.bold,
                                  size: 13,
                                ),
                                const SizedBox(height: 1),
                                ReusableText(
                                  title: event.Location!.length > 25
                                      ? '${event.Location!.substring(0, 25)}...'
                                      : event.Location,
                                  color: AppColor.hintColor,
                                  size: 8,
                                  weight: FontWeight.bold,
                                ),
                                const SizedBox(height: 3),
                                ReusableText(
                                  title: event.date,
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
                                ReusableText(
                                  title: event.price,
                                  color: AppColor.btnColor,
                                  weight: FontWeight.bold,
                                  size: 16,
                                ),
                                const ReusableText(
                                  title: "\AED ",
                                  color: AppColor.btnColor,
                                  weight: FontWeight.bold,
                                  size: 16,
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
          );
        },
      ),
    );
  }
}
