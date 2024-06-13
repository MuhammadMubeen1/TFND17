import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:tfnd_app/models/AddUserModel.dart';
import 'package:tfnd_app/screens/subscription.dart';
import 'package:tfnd_app/themes/color.dart';
 // Adjust as per your file structure

class ChatController extends ChangeNotifier {
  final TextEditingController descriptionController = TextEditingController();
  AddUserModel? userData;
  final ScrollController scrollController = ScrollController();
  final SubscriptionService subscriptionService = SubscriptionService();

  List<DocumentSnapshot> posts = [];
  String? isPaid;

  // Initialize controller state
  void init(String userEmail) {
    listenToUserData(userEmail);
    fetchPosts();
  }

  // Fetch user data and listen to changes
  void listenToUserData(String currentUserEmail) {
    try {
      FirebaseFirestore.instance
          .collection('RegisterUsers')
          .where('email', isEqualTo: currentUserEmail)
          .snapshots()
          .listen((QuerySnapshot userSnapshot) {
        if (userSnapshot.docs.isNotEmpty) {
          AddUserModel? user = AddUserModel.fromJson(
              userSnapshot.docs.first.data() as Map<String, dynamic>);

          if (user!.subscription!.isNotEmpty) {
            isPaid = user.subscription;
          } else {
            isPaid = null; // Handle no subscription scenario
          }
          userData = user;
          notifyListeners();
        }
      });
    } catch (e) {
      print("Error listening to user data: $e");
    }
  }

  // Fetch posts from Firestore
  void fetchPosts() {
    try {
      FirebaseFirestore.instance
          .collection('Posts')
          .orderBy('count', descending: true)
          .snapshots()
          .listen((QuerySnapshot snapshot) {
        posts = snapshot.docs;
        notifyListeners();
      });
    } catch (e) {
      print("Error fetching posts: $e");
    }
  }

  // Post a message
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
          textColor: Colors.black,
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
          textColor: Colors.black,
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
        textColor: Colors.black,
        fontSize: 16.0,
      );
    }
  }

  // Like a post
  Future<void> likePost(String postId, String userId) async {
    DocumentReference postRef =
        FirebaseFirestore.instance.collection('Posts').doc(postId);

    // Get the current likedBy array from Firestore
    var postSnapshot = await postRef.get();
    var postData = postSnapshot.data();
    if (postData is Map<String, dynamic>) {
      var likedBy = List<String>.from(postData['likedBy'] ?? []);

      // Toggle like status
      if (likedBy.contains(userId)) {
        // User already liked the post, so unlike it
        likedBy.remove(userId);
      } else {
        // User didn't like the post yet, so like it
        likedBy.add(userId);
      }

      // Update like count and likedBy array in Firestore
      await postRef.update({
        'likeCount': likedBy.length,
        'likedBy': likedBy,
      });

      notifyListeners();
    } else {
      print('Post data is not a Map<String, dynamic>');
    }
  }

  // Clean up resources
  @override
  void dispose() {
    descriptionController.dispose();
    scrollController.dispose();
    super.dispose();
  }
}
