import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class AddUserModel {
  String? name;
  String? email;
  String? password;
  String? phoneNumber;
  String? image;
   String? completenumber;
  String? verification;
  String? subscription;
  String? restriction;
  String? date;
  String ?counter;
  String? Nationality;
  String? Location;
  String? State;
  String? time;
  int? uid;
  String? industeries;
  String? nextDueDate;
  String? firstDate;
  String? Countryyy;
 String?  phonecode;
  AddUserModel({
    this.counter,
    this.email,
    this.name,
    this.phonecode,
    this.nextDueDate,
    this.industeries,
    this.State,
    this.Countryyy,
    this.verification,
    this.completenumber,
    this.password,
    this.Nationality,
    this.Location,
    this.firstDate,
    this.date,
    this.time,
    this.phoneNumber,
    this.image,
    this.restriction,
    this.subscription,
    this.uid,
  });

  Map<String, dynamic> toJson() {
    return {
      "counter":counter,
      "email": email,
      "completenumber":completenumber,
      "name": name,
      "phonecode":phonecode,
      "date": date,
      "industeries": industeries,
      "nextDueDate":nextDueDate,
      "State": State,
      "Location": Location,
      "firstDate":firstDate,
      "Nationality": Nationality,
      "Countryyy": Countryyy,
      "password": password,
      "verification": verification,
      "phoneNumber": phoneNumber,
      "image": image,
      "time": time,
      "subscription": subscription,
      "uid": uid,
    
      "restriction": restriction,
    };
  }

  factory AddUserModel.fromJson(Map<String, dynamic> json) {
    return AddUserModel(
      email: json["email"] ?? "",
      completenumber: json['completenumber']??"",
      phonecode: json['phonecode']??"",
      date: json["date"] ?? "",
      Location: json["Location"] ?? "",
      name: json["name"] ?? "",
      firstDate:json["firstDate"]??"",
      State: json["State"] ?? "",
      industeries: json["industeries"]??"",
      time: json["time"] ?? "",
      nextDueDate:json["nextDueDate"],
      Nationality: json["Nationality"] ?? "",
      password: json["password"] ?? "",
      phoneNumber: json["phoneNumber"] ?? "",
      Countryyy:json["Countryyy"]??"",
      image: json["image"] ?? "",
      subscription: json["subscription"] ?? "",
      uid: json["uid"] ?? "",
      counter:json["counter"]??"",
      verification: json["verfication"] ?? "",
   
    );
  }
}
