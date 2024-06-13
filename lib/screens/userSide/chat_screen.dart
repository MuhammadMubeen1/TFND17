import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tfnd_app/models/AddUserModel.dart';
import 'package:tfnd_app/screens/comment.dart';
import 'package:tfnd_app/screens/subscription.dart';
import 'package:tfnd_app/screens/userSide/scanner.dart';
import 'package:tfnd_app/themes/color.dart';
import 'package:tfnd_app/widgets/reusable_text.dart';
import 'package:tfnd_app/widgets/status_update.dart';

class Chat extends StatefulWidget {
  final String? userEmail; // User's ail
  const Chat({Key? key, required this.userEmail}) : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController descriptionController = TextEditingController();
  AddUserModel? userData;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final SubscriptionService _subscriptionService = SubscriptionService();

  List<DocumentSnapshot> posts = [];
  String? lastDisplayedDate;
  bool _isSubscribing = false;
  String? isPaid;
  @override
  void dispose() {
    descriptionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void initState() {
    super.initState();

    listenToUserData(widget.userEmail.toString());
  }

  Future<void> listenToUserData(String currentUserEmail) async {
    try {
      FirebaseFirestore.instance
          .collection('RegisterUsers')
          .where('email', isEqualTo: currentUserEmail)
          .snapshots()
          .listen((QuerySnapshot userSnapshot) {
        if (userSnapshot.docs.isNotEmpty) {
          AddUserModel? userData = AddUserModel.fromJson(
              userSnapshot.docs.first.data() as Map<String, dynamic>);

          if (userData!.subscription!.isNotEmpty) {
            setState(() {
              isPaid = userData!.subscription;
            });
            print("Subscription status: $isPaid");
          } else {
            print("No subscription found");
          }
        }
      });
    } catch (e) {
      print("Error listening to user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColor.bgColor,
        appBar: AppBar(
          backgroundColor: AppColor.bgColor,
          automaticallyImplyLeading: true,
          iconTheme: const IconThemeData(
            color: AppColor.hintColor,
          ),
          centerTitle: true,
          title: const ReusableText(
            title: "Posts",
            color: Colors.black,
            size: 20,
            weight: FontWeight.w500,
          ),
        ),
        body: isPaid == null
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColor.blackColor,
                ), // Show circular progress indicator while checking subscription status
              )
            : isPaid == "paid"
                ? FutureBuilder(
                    future: getUserData(widget.userEmail.toString()),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      // Build UI once userData is fetched
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection('Posts')
                                  .orderBy('count',
                                      descending:
                                          true) // Order posts based on count
                                  .snapshots(),
                              builder: (context,
                                  AsyncSnapshot<QuerySnapshot> snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator(
                                    color: AppColor.blackColor,
                                  ));
                                }
                                if (snapshot.hasError) {
                                  return Center(
                                      child: Text('Error: ${snapshot.error}'));
                                }

                                // Check if there are no posts
                                if (snapshot.data!.docs.isEmpty) {
                                  // Show a message or widget indicating no posts available
                                  return const Center(
                                    child: Text('No posts available'),
                                  );
                                }

                                // Clear the list before adding new posts
                                posts.clear();

                                // Add all retrieved posts to the list
                                posts.addAll(snapshot.data!.docs);

                                // Initialize the AnimatedList with initial items
                                return AnimatedList(
                                  key: _listKey,
                                  controller: _scrollController,
                                  reverse: true,
                                  initialItemCount: posts.length,
                                  itemBuilder: (context, index, animation) {
                                    if (index >= posts.length) {
                                      return const SizedBox.shrink();
                                    }
                                    final post = posts[index];
                                    final time = post['time'] as String;

                                    // Extracting the date from the post time
                                    final postDate = DateFormat('MMM dd, yyyy')
                                        .format(DateTime
                                            .now()); // Change this line as per your date format

                                    Widget postItem =
                                        buildPostItem(post, time, animation);

                                    // Checking if the post date is different from the last displayed date
                                    if (postDate != lastDisplayedDate) {
                                      // If different, display the post date
                                      postItem = Column(
                                        children: [
                                          Text(
                                            postDate,
                                            style: const TextStyle(
                                              color: AppColor.textColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(
                                              height:
                                                  8), // Adjust spacing as needed
                                          postItem,
                                        ],
                                      );
                                      // Update the last displayed date
                                      lastDisplayedDate = postDate;
                                    }

                                    return Column(
                                      children: [
                                        buildPostItem(post, time, animation),
                                        const Divider(
                                            height: 8.0,
                                            color: Colors.grey), // Add divider
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: Color(0xFFFFEBF2),
                                borderRadius: BorderRadius.circular(16.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: Offset(10, 10),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: (userData?.image != null &&
                                            userData!.image!.isNotEmpty)
                                        ? NetworkImage(
                                                userData!.image! as String)
                                            as ImageProvider<Object>?
                                        : const AssetImage(
                                            "assets/images/tfndlog.jpg"),
                                    radius: 20,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: TextFormField(
                                      maxLines: null,
                                      cursorColor: Colors.white,
                                      controller: descriptionController,
                                      style: const TextStyle(
                                          color: AppColor.textColor),
                                      decoration: const InputDecoration(
                                        hintText: 'Type a message',
                                        hintStyle: TextStyle(
                                            color: AppColor.textColor,
                                            fontWeight: FontWeight.bold),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 15.0),
                                        fillColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.send,
                                      color: AppColor.btnColor,
                                    ),
                                    onPressed: () async {
                                      await sendPost();
                                      // Scroll to the top asifter sending a
                                      _scrollController.animateTo(0,
                                          duration: Duration(milliseconds: 500),
                                          curve: Curves.easeInOut);
                                      FocusScope.of(context)
                                          .requestFocus(FocusNode());
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      );
                    },
                  )
                : Center(
                    child: Container(
                      width: 310,
                      height: 450,
                      decoration: BoxDecoration(
                        color: AppColor.btnColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            offset: Offset(4, 4),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                          BoxShadow(
                            color: Colors.white,
                            offset: Offset(-4, -4),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                        gradient: const LinearGradient(
                          colors: [AppColor.bgColor, AppColor.bgColor],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 30),
                            child: Image(
                              height: 140,
                              image: AssetImage(
                                "assets/images/tfndd.png",
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 18.0),
                            child: Text(
                              "Get access to exclusive content by subscribing to our post updates. Enjoy a seamless experience with premium features!",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColor.textColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 100,
                          ),
                          Center(
                            child: GestureDetector(
                              onTap: () async {
                                if (!_isSubscribing) {
                                  // Check if not already subcribing
                                  setState(() {
                                    _isSubscribing =
                                        true; // Start subscribing process
                                  });
                                  await _subscriptionService
                                      .showSubscriptionPopup(
                                          context, widget.userEmail.toString());
                                  setState(() {
                                    _isSubscribing =
                                        false; // End subscribing process
                                  });
                                }
                              },
                              child: Container(
                                height: 50,
                                width: 250,
                                decoration: BoxDecoration(
                                  color: AppColor.btnColor,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.5),
                                      offset: Offset(0, 3),
                                      blurRadius: 6,
                                      spreadRadius: 0,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    "Subscribe Now"!,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ));
  }

  Widget buildPostItem(
      DocumentSnapshot post, String time, Animation<double> animation) {
    // Split the time string to extract hours, minutes, and seconds
    final parts = time.split(':');
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);

    // Format the time in hours and minutes with AM/PM indicator
    final formattedTime = DateFormat('h:mm');

    // Get the current date
    final currentDate = DateTime.now();

    // Format the current date in 'MMM dd, yyyy' format
    final formattedDate = DateFormat('MMM dd yyy').format(currentDate);

    return SizeTransition(
      sizeFactor: animation,
      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: 0.0,
          horizontal: 16.0,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFFFFEBF2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundImage:
                    (post['image'] != null && post['image'].isNotEmpty)
                        ? NetworkImage(post['image']) as ImageProvider<Object>?
                        : const AssetImage("assets/images/tfndlog.jpg"),
                radius: 20,
              ),
              title: Text(
                post['name'] as String,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColor.blackColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  post['description'] as String,
                  style: const TextStyle(
                    color: AppColor.textColor,
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.favorite,
                        color: post['likedBy'] != null &&
                                post['likedBy']
                                    .contains(userData!.uid.toString())
                            ? Colors.red
                            : Color(0xffe597a7),
                      ),
                      onPressed: () {
                        likePost(post.id,
                            userData!.uid.toString()); // Pass userId here
                      },
                    ),
                    Text(
                      post['likeCount'] != null
                          ? post['likeCount'].toString()
                          : '0',
                      style: const TextStyle(
                        color: AppColor.textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${post['time']} on ${post['date']}',
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.comment,
                    color: Color(0xffe597a7),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TestMe(
                          postId: post.id,
                          name: userData!.name.toString(),
                          pic: userData!.image.toString(),
                          curreentname: userData!.name.toString(),
                          curreentpic: userData!.image.toString(),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<AddUserModel?> getUserData(String currentUserEmail) async {
    try {
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('RegisterUsers')
          .where('email', isEqualTo: currentUserEmail)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        userData = AddUserModel.fromJson(
            userSnapshot.docs.first.data() as Map<String, dynamic>);

        return userData;
      }
    } catch (e) {
      print("Error fetching user data: $e");
      return null;
    }
  }

  Future<void> sendPost() async {
    if (descriptionController.text.isNotEmpty) {
      try {
        final currentTime = DateTime.now();
        final currentTimeString = '${currentTime.hour}:${currentTime.minute}:';
        final currentDate = DateFormat('MMM dd, yyyy').format(currentTime);

        final QuerySnapshot countSnapshot = await FirebaseFirestore.instance
            .collection('Posts')
            .orderBy('count', descending: true)
            .get();

        int latestCount = 1; // Default count for the first post
        if (countSnapshot.docs.isNotEmpty) {
          final Map<String, dynamic>? latestData =
              countSnapshot.docs.first.data() as Map<String, dynamic>?;
          if (latestData != null && latestData.containsKey('count')) {
            latestCount = (latestData['count'] as int) + 1;
          }
        }

        // Null check for userData
        if (userData != null) {
          await FirebaseFirestore.instance.collection('Posts').add({
            "name": userData!.name.toString(),
            'description': descriptionController.text,
            'time': currentTimeString,
            'date': currentDate, // Save the current date
            'image': userData!.image.toString(),
            'likeCount': 0,
            'likedBy': [],
            'comments': [],
            'count': latestCount, // Assign count to the post
          });
        }

        descriptionController.clear();

        Fluttertoast.showToast(
          msg: 'Post added successfully!',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: AppColor.btnColor,
          textColor: AppColor.blackColor,
          fontSize: 16.0,
        );
      } catch (error) {
        print('Error: $error');
        Fluttertoast.showToast(
          msg: 'Failed to add post!',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: AppColor.btnColor,
          textColor: AppColor.blackColor,
          fontSize: 16.0,
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: 'Please enter a post description!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
         backgroundColor: AppColor.btnColor,
           textColor: AppColor.blackColor,
        fontSize: 16.0,
      );
    }
  }

  Future<void> likePost(String postId, String userId) async {
    DocumentReference postRef =
        FirebaseFirestore.instance.collection('Posts').doc(postId);

    // Get the current likedBy array from Firestore
    var postSnapshot = await postRef.get();
    var postData = postSnapshot.data();
    if (postData is Map<String, dynamic>) {
      var likedBy = List<String>.from(postData['likedBy'] ?? []);

      print('Liked By Before: $likedBy');

      // Toggle like status
      if (likedBy.contains(userId)) {
        // User already liked the post, so unlike it
        likedBy.remove(userId);
      } else {
        // User didn't like the post yet, so like it
        likedBy.add(userId);
      }

      print('Liked By After: $likedBy'); // Print updated likedBy list

      // Update like count and likedBy array in Firestore
      await postRef.update({
        'likeCount': likedBy.length,
        'likedBy': likedBy,
      });

      // Update UI
    } else {
      print('Post data is not a Map<String, dynamic>');
    }
  }
}