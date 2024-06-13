import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comment_box/comment/comment.dart';
import 'package:tfnd_app/themes/color.dart';
import 'package:intl/intl.dart';

class TestMe extends StatefulWidget {
  final String postId;
  final String name;
  final String pic;
  final String curreentname;
  final String curreentpic;

  TestMe({
    required this.postId,
    required this.name,
    required this.pic,
    required this.curreentname,
    required this.curreentpic,
  });

  @override
  _TestMeState createState() => _TestMeState();
}

class _TestMeState extends State<TestMe> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController commentController = TextEditingController();

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  CollectionReference postsCollection =
      FirebaseFirestore.instance.collection('Posts');

  Widget commentChild(List data, String postId) {
    return FutureBuilder(
      future: postsCollection.doc(postId).collection('comments').get(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        List<DocumentSnapshot> commentDocs = snapshot.data!.docs;

        List<Widget> commentWidgets = [];

        // Adding comments and dividers to the list of widgets
        for (var i = 0; i < data.length; i++) {
          commentWidgets.add(
            Padding(
              padding: const EdgeInsets.fromLTRB(2.0, 8.0, 2.0, 0.0),
              child: ListTile(
                leading: GestureDetector(
                  onTap: () async {
                    // Display the image in large form.
                    print("Comment Clicked");
                  },
                  child: Container(
                    height: 50.0,
                    width: 50.0,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: data[i]['pic'] != null
                          ? CommentBox.commentImageParser(
                              imageURLorPath: data[i]['pic'])
                          : const AssetImage(
                              'assets/images/tfndlog.jpg'), // Assuming 'assets/tend_log_image.' is our pr image
                    ),
                  ),
                ),
                title: Text(
                  widget.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data[i]['message']),
                    Text(
                      '${data[i]['time']} on ${data[i]['date']}',
                      style: const TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
          );
          // Add divider after each comment except the last one
          if (i < data.length - 1) {
            commentWidgets.add(
              Divider(
                color: Colors.grey,
                thickness: 1.0,
                height: 0.0,
              ),
            );
          }
        }

        // Adding comments from Firestore and dividers to the list of widgets
        for (var doc in commentDocs) {
          commentWidgets.add(
            Padding(
              padding: const EdgeInsets.fromLTRB(2.0, 8.0, 2.0, 0.0),
              child: ListTile(
                leading: GestureDetector(
                  onTap: () async {
                    // Display the image in large form.
                    print("Comment Clicked");
                  },
                  child: Container(
                    height: 50.0,
                    width: 50.0,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: (doc['pic'] != null &&
                              doc['pic'].isNotEmpty)
                          ? CommentBox.commentImageParser(
                              imageURLorPath: doc['pic'])
                          : const AssetImage(
                              'assets/images/tfndlog.jpg'), // Placeholder image
                    ),
                  ),
                ),
                title: Text(

                  doc['name'],
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(doc['message']),
                      SizedBox(height: 5,),
                      Text(
                        '${doc['time']} on ${doc['date']}',
                        style: const TextStyle(fontSize: 12 , fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
          // Add divider after each comment except the last one
          if (commentDocs.indexOf(doc) < commentDocs.length - 1) {
            commentWidgets.add(
              Divider(
                color: Colors.grey,
                thickness: 1.0,
                height: 15,
              ),
            );
          }
        }

        return ListView(
          children: commentWidgets,
        );
      },
    );
  }

  Future<int> getCommentCount() async {
    var querySnapshot =
        await postsCollection.doc(widget.postId).collection('comments').get();

    return querySnapshot.size;
  }

  Future<void> addComment() async {
    var now = DateTime.now();
    var formattedDate = DateFormat('yyyy-MM-dd').format(now);
    var formattedTime = DateFormat('HH:mm').format(now);

    var commentData = {
      'name': widget.curreentname.toString(),
      'pic': widget.curreentpic.toString(),
      'message': commentController.text,
      'time': formattedTime,
      'date': formattedDate,
    };

    await postsCollection
        .doc(widget.postId)
        .collection('comments')
        .add(commentData);

    commentController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgColor,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: FutureBuilder<int>(
          future: getCommentCount(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text(
                "Comment:",
                style: TextStyle(color: Colors.white),
              );
            } else {
              return Text(" ${snapshot.data} Comments",
                  style: const TextStyle(
                    color: Colors.white,
                  ));
            }
          },
        ),
        backgroundColor: AppColor.blackColor,
      ),
      body: Container(
        child: CommentBox(
          userImage: (widget.curreentpic != null &&
                  widget.curreentpic.isNotEmpty)
              ? CommentBox.commentImageParser(
                  imageURLorPath: widget.curreentpic.toString())
              : const AssetImage('assets/images/tfndlog.jpg'), // Default image
          child: commentChild([], widget.postId),
          labelText: 'Write a comment...',
          errorText: 'Comment cannot be blank',
          withBorder: false,
          sendButtonMethod: () async {
            if (formKey.currentState!.validate()) {
              await addComment();
            } else {
              print("Not validated");
            }
          },
          formKey: formKey,
          commentController: commentController,
          backgroundColor: AppColor.blackColor,
          textColor: Colors.white,
          sendWidget:
              const Icon(Icons.send_sharp, size: 30, color: Colors.white),
        ),
      ),
    );
  }
}
