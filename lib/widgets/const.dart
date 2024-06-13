import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tfnd_app/themes/color.dart';

class StaticInfo {
  static const registerUser = "RegisterUsers";
  static const businessRegister = "BusinessRegister";
  static const businessCategory = "BusinessCategory";
  static const eventRegister = "EventRegister";
  static const posts = "Posts";
}

Widget titleForDialog(BuildContext context, String title) {
  return Container(
    color: AppColor.primaryColor,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
    child: Center(
      child: Text(title,
          style:
              const TextStyle(color: Colors.white, fontSize: 17, height: 1.55),
          textAlign: TextAlign.center),
    ),
  );
}

class FirebaseApi {
  static UploadTask? uploadFile(String destination, File file) {
    try {
      final ref = FirebaseStorage.instance.ref(destination);

      return ref.putFile(file);
    } on FirebaseException catch (e) {
      return null;
    }
  }

  static UploadTask? uploadBytes(String destination, Uint8List data) {
    try {
      final ref = FirebaseStorage.instance.ref(destination);

      return ref.putData(data);
    } on FirebaseException catch (e) {
      return null;
    }
  }
}
