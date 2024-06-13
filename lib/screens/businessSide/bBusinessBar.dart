

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tfnd_app/Controllors/my_business_controllor.dart';
import 'package:tfnd_app/models/AddBusinessModel.dart';
import 'package:tfnd_app/screens/businessSide/addBusiness.dart';
import 'package:tfnd_app/screens/businessSide/businessDet.dart';
import 'package:tfnd_app/themes/color.dart';
import 'package:tfnd_app/widgets/reusable_text.dart';


class BusinessBar extends StatelessWidget {
  final String emailuser;

  BusinessBar({super.key, required this.emailuser});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BusinessBarController(emailuser),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColor.bgColor,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: const ReusableText(
            title: "Business",
            color: AppColor.blackColor,
            size: 20,
            weight: FontWeight.w500,
          ),
          actions: const [
            SizedBox(
              width: 20,
            )
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                Container(
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
                          builder: (BuildContext context) => addBusiness(
                            useremail: emailuser,
                          ),
                        ),
                      );
                    },
                    child: const Center(
                      child: ReusableText(
                        title: "Add New Business",
                        color: AppColor.blackColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Expanded(
                  child: Consumer<BusinessBarController>(
                    builder: (context, controller, child) {
                      return StreamBuilder<List<AddBusinessModel>>(
                        stream: controller.businessStream,
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Text('No businesses available.');
                          } else {
                            List<AddBusinessModel> businesses = snapshot.data!;
                            return GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 15.0,
                                mainAxisSpacing: 30.0,
                                mainAxisExtent: 220,
                              ),
                              itemCount: businesses.length,
                              itemBuilder: (BuildContext context, int index) {
                                return GestureDetector(
                                  onTap: () {
                                    controller.updateClickCount(
                                        businesses[index].uid.toString());
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute<void>(
                                        builder: (BuildContext context) =>
                                            BusinessDet(
                                          business: businesses[index],
                                          emaildetails: emailuser,
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
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
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
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Center(
                                        child: Container(
                                          width: 120,
                                          child: ReusableText(
                                            textAlign: TextAlign.center,
                                            title: businesses[index].name,
                                            color: AppColor.darkTextColor,
                                            size: 10,
                                            weight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      ReusableText(
                                        title: businesses[index].category,
                                        color: AppColor.hintColor,
                                        size: 10,
                                        weight: FontWeight.bold,
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
                                );
                              },
                            );
                          }
                        },
                      );
                    },
                  ),
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
