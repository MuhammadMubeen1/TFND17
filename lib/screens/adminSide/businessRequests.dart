import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tfnd_app/screens/adminSide/aBusinessDetails.dart';
import 'package:tfnd_app/themes/color.dart';
import 'package:tfnd_app/widgets/reusable_text.dart';

class BusinessRequests extends StatefulWidget {
  BusinessRequests({
    Key? key,
    required this.mub,
  }) : super(key: key);

  final String mub;

  @override
  State<BusinessRequests> createState() => _BusinessRequestsState();
}

class _BusinessRequestsState extends State<BusinessRequests> {
  late Stream<QuerySnapshot> _requestsStream;
  late List<DocumentSnapshot> _requests = [];
  var request;
  String filter = 'all'; // Default filter set to 'all'

  @override
  void initState() {
    _requestsStream = FirebaseFirestore.instance
        .collection('requests')
        .orderBy('time', descending: true) // Order by timestamp in descending order
        .snapshots();
  
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.bgColor,
        iconTheme: const IconThemeData(
          color: AppColor.hintColor,
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: GestureDetector(
            onTap: () {},
          ),
        ),
        title: const ReusableText(
          title: "Business Requests",
          color: AppColor.blackColor,
          size: 20,
          weight: FontWeight.w500,
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.search_outlined,
              size: 28,
              color: AppColor.hintColor,
            ),
            onPressed: () {
              showSearch(
                context: context,
                delegate: RequestSearchDelegate(requests: _requests),
              );
            },
          ),
          const SizedBox(
            width: 20,
          )
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 5,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
             ElevatedButton(
  onPressed: () {
    setState(() {
      filter = 'pending';
    });
  },
 child: Padding(
    padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0), // Adjust padding as needed
    child: Icon(
  Icons.pending_actions_sharp, // Icon name
  color: AppColor.btnColor, // Icon color
  size: 24, // Icon size
),
  ),
  style: ButtonStyle(
    shape: MaterialStateProperty.all<OutlinedBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), // Adjust the radius as needed
        side: const BorderSide(
          color: AppColor.btnColor, // Adjust the color as needed
        ),
      ),
    ),
  ),
),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    filter = 'rejected';
                  });
                },
                child:  Image.asset(
  'assets/images/cancel.png', // Path to your image asset
  width: 20, // Width of the image
  height: 20,
  color: AppColor.btnColor, // Height of the image
),
    
               style: ButtonStyle(
                        shape: MaterialStateProperty.all<OutlinedBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                20), // Adjust the radius as needed
                            side: const BorderSide(
                                color: AppColor
                                    .btnColor), // Adjust the color as needed
                          ),
                        ),
                      ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    filter = 'approved';
                  });
                },
                child: Image.asset(
  'assets/images/ok.png', // Path to your image asset
  width: 24, // Width of the image
  height: 24,
  color: AppColor.btnColor, // Height of the image
),
              style: ButtonStyle(
                        shape: MaterialStateProperty.all<OutlinedBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                20), // Adjust the radius as needed
                            side: const BorderSide(
                                color: AppColor
                                    .btnColor), // Adjust the color as needed
                          ),
                        ),
                      ),
              ),

               ElevatedButton(
                onPressed: () {
                  setState(() {
                    filter = 'all';
                  });
                },

              child: Image.asset(
  'assets/images/all.png', // Path to your image asset
  width: 24, // Width of the image
  height: 24,
  color: AppColor.btnColor, // Height of the image
),
              style: ButtonStyle(
                        shape: MaterialStateProperty.all<OutlinedBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                20), // Adjust the radius as needed
                            side: const BorderSide(
                                color: AppColor
                                    .btnColor), // Adjust the color as needed
                          ),
                        ),
                      ),
              ),
            ],
          ),

              const  SizedBox(height: 10,),
          Expanded(
            child: StreamBuilder(
              stream: _requestsStream,
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                _requests = snapshot.data!.docs;

                // Filter requests based on the selected status or show all if filter is 'all'
                List<DocumentSnapshot> filteredRequests =
                    (filter == 'all') ? _requests : _requests.where((request) => request['status'] == filter).toList();

                return ListView.builder(
                  itemCount: filteredRequests.length,
                  itemBuilder: (context, index) {
                    request = filteredRequests[index];
                    return Column(
                      children: [
                        ListTile(
                          trailing: ReusableText(
                            title: "${request['date']}",
                            color: AppColor.hintColor,
                            weight: FontWeight.w600,
                            size: 11,
                          ),
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(request['imageUrl']),
                            radius: 35,
                          ),
                          title: ReusableText(
                            title: "${request['userName']}",
                            color: AppColor.darkTextColor,
                            weight: FontWeight.w600,
                            size: 13.5,
                          ),
                          subtitle: ReusableText(
                            title: "${request['status']}",
                            color: AppColor.textColor,
                            weight: FontWeight.w600,
                            size: 11,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (BuildContext context) => aBusinessDetails(
                                  requestData: filteredRequests[index].data() as Map<String, dynamic>,
                                ),
                              ),
                            );
                          },
                        ),
                        const Divider(
                          color: AppColor.hintColor,
                          thickness: 0.5,
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class RequestSearchDelegate extends SearchDelegate<String> {
  final List<DocumentSnapshot> requests;
  List<DocumentSnapshot> filteredRequests = [];

  RequestSearchDelegate({required this.requests});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Filter requests based on the search query
    filteredRequests = _filterRequests(query);

    return _buildSearchResults(filteredRequests);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Filter requests based on the search query
    filteredRequests = _filterRequests(query);

    return _buildSearchResults(filteredRequests);
  }

  Widget _buildSearchResults(List<DocumentSnapshot> results) {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        var request = results[index];

        return Column(
          children: [
            ListTile(
              trailing: const ReusableText(
                title: "",
                color: AppColor.hintColor,
              ),
              leading: CircleAvatar(
                backgroundImage: NetworkImage(request['imageUrl']),
                radius: 35,
              ),
              title: ReusableText(
                title: "${request['userName']}",
                color: AppColor.darkTextColor,
                weight: FontWeight.w600,
                size: 13.5,
              ),
              subtitle: ReusableText(
                title: "${request['status']}",
                color: AppColor.textColor,
                weight: FontWeight.w600,
                size: 11,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => aBusinessDetails(
                      requestData: results[index].data() as Map<String, dynamic>,
                    ),
                  ),
                );
              },
            ),
            const Divider(
              color: AppColor.hintColor,
              thickness: 0.3,
            ),
          ],
        );
      },
    );
  }

  List<DocumentSnapshot> _filterRequests(String query) {
    final List<DocumentSnapshot> filteredList = [];

    for (var request in requests) {
      // Include all requests if the query is empty or the filter is set to 'all'
      if (query.isEmpty || request['userName'].toString().toLowerCase().contains(query.toLowerCase())) {
        filteredList.add(request);
      }
    }

    return filteredList;
  }
}
