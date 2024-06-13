import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tfnd_app/Controllors/business_controllor.dart';

import 'package:tfnd_app/models/AddBusinessModel.dart';
import 'package:tfnd_app/screens/userSide/businessDetails.dart';
import 'package:tfnd_app/themes/color.dart';
import 'package:tfnd_app/widgets/reusable_text.dart';
import 'package:tfnd_app/widgets/status_update.dart';

class BusinessBar extends StatefulWidget {
  final String cureeemils;

  const BusinessBar({Key? key, required this.cureeemils}) : super(key: key);

  @override
  State<BusinessBar> createState() => _BusinessBarState();
}

class _BusinessBarState extends State<BusinessBar> {


    void initState() {
      
    super.initState();

  
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BusinessController(),
      child: Scaffold(
        backgroundColor: AppColor.bgColor,
        appBar: AppBar(
          backgroundColor: AppColor.bgColor,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: const ReusableText(
            title: "Businesses at TFND",
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
                    builder: (context) => BusinessSearchScreen(
                      email: widget.cureeemils,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Consumer<BusinessController>(
            builder: (context, controller, _) {
              return Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.only(left: 18, right: 18),
                    child: TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        filled: true,
                        fillColor: AppColor.bgColor,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 0.0, horizontal: 10.0),
                        suffixIcon: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            dropdownColor: AppColor.bgColor,
                            icon: const Icon(Icons.arrow_drop_down),
                            iconSize: 30,
                            isExpanded: true,
                            items: controller.allCategories
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Row(
                                  children: [
                                    const SizedBox(width: 10),
                                    Text(value),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              controller.selectedCategory = newValue;
                              controller.filterBusinessesByCategory(newValue);
                            },
                            value: controller.selectedCategory,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 15.0,
                          mainAxisSpacing: 30.0,
                          mainAxisExtent: 220),
                      itemCount: controller.selectedCategory == "All"
                          ? controller.businesses.length
                          : controller.filteredBusinesses.length,
                      itemBuilder: (BuildContext context, int index) {
                        final business = controller.selectedCategory == "All"
                            ? controller.businesses[index]
                            : controller.filteredBusinesses[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (BuildContext context) => businessDets(
                                  business: business,
                                  emaildetails: widget.cureeemils,
                                  cureeemails: widget.cureeemils,
                                ),
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              business.image == null ||
                                      business.image!.isEmpty ||
                                      business.image == ""
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
                                                  business.image.toString()),
                                              fit: BoxFit.cover)),
                                    ),
                              const SizedBox(height: 7),
                              ReusableText(
                                title: business.name,
                                color: AppColor.darkTextColor,
                                size: 12,
                                weight: FontWeight.bold,
                              ),
                              const SizedBox(height: 2),
                              ReusableText(
                                title: business.category,
                                color: AppColor.hintColor,
                                size: 10,
                                weight: FontWeight.bold,
                              ),
                              const SizedBox(height: 4),
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
                                    title: business.discount,
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
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class BusinessSearchScreen extends StatefulWidget {
  final String email;

  const BusinessSearchScreen({Key? key, required this.email}) : super(key: key);

  @override
  State<BusinessSearchScreen> createState() => _BusinessSearchScreenState();
}

class _BusinessSearchScreenState extends State<BusinessSearchScreen> {
  final FocusNode searchFocusNode = FocusNode();

   void initState() {
    super.initState();
    // Request focus when the screen is loaded
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(searchFocusNode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BusinessController(),
      child: Consumer<BusinessController>(
        builder: (context, controller, _) {
          return Scaffold(
            appBar: AppBar(
              title: TextField(
              focusNode: searchFocusNode,
                controller: controller.searchController,
                onChanged: (value) {
                  controller.filterBusinesses(value);
                },
                decoration: const InputDecoration(
                  hintText: 'Search business by name ',
                  border: InputBorder.none,
                ),
              ),
            ),
            body: ListView.builder(
              itemCount: controller.filteredBusinesses.length,
              itemBuilder: (context, index) {
                final business = controller.filteredBusinesses[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) => businessDets(
                            business: business,
                            emaildetails: widget.email,
                            cureeemails: widget.email,
                          ),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        business.image == null ||
                                business.image!.isEmpty ||
                                business.image == ""
                            ? Container(
                                height: 130,
                                width: 130,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    image: const DecorationImage(
                                        image: AssetImage(
                                            "assets/images/tfndlog.jpg"),
                                        fit: BoxFit.cover)),
                              )
                            : Container(
                                height: 130,
                                width: 130,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    image: DecorationImage(
                                        image: NetworkImage(
                                            business.image.toString()),
                                        fit: BoxFit.cover)),
                              ),
                        const SizedBox(height: 7),
                        ReusableText(
                          title: business.name,
                          color: AppColor.darkTextColor,
                          size: 12,
                          weight: FontWeight.bold,
                        ),
                        const SizedBox(height: 2),
                        ReusableText(
                          title: business.category,
                          color: AppColor.hintColor,
                          size: 10,
                          weight: FontWeight.bold,
                        ),
                        const SizedBox(height: 2),
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
                              title: business.discount,
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
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
