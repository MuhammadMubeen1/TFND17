import 'package:flutter/material.dart';
import 'package:tfnd_app/themes/color.dart';
import 'package:tfnd_app/widgets/reusable_text.dart';

class allEvents extends StatefulWidget {
  const allEvents({super.key});

  @override
  State<allEvents> createState() => _allEventsState();
}

class _allEventsState extends State<allEvents> {
  final List items = [
    "Luxary Abaya Collection",
    "Cultural Abaya Collection",
    "Premium Abaya Collection",
    "Luxary Abaya Collection"
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return Stack(
            children: [
              Container(
                height: 210,
                width: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: const DecorationImage(
                        image: AssetImage("assets/images/event2.webp"))),
              ),
              Positioned(
                  top: 140,
                  left: 20,
                  right: 20,
                  child: Container(
                    height: 70,
                    width: 310,
                    decoration: BoxDecoration(
                        color: AppColor.backgroundColor,
                        borderRadius: BorderRadius.circular(15)),
                    child: Row(
                      children: [
                       const SizedBox(
                          width: 20,
                        ),
                       const  Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ReusableText(
                              title: "JAN",
                              color: AppColor.primaryColor,
                              size: 11.5,
                              weight: FontWeight.bold,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            ReusableText(
                              title: "31",
                              color: AppColor.primaryColor,
                              size: 18,
                              weight: FontWeight.bold,
                            )
                          ],
                        ),
                       const  SizedBox(
                          width: 20,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ReusableText(
                              title: items[index],
                              color: AppColor.blackColor,
                              weight: FontWeight.bold,
                            ),
                           const   SizedBox(
                              height: 5,
                            ),
                          const   ReusableText(
                              title: "New York, US",
                              color: AppColor.hintColor,
                              size: 11,
                              weight: FontWeight.bold,
                            )
                          ],
                        )
                      ],
                    ),
                  ))
            ],
          );
        },
      ),
    );
  }
}
