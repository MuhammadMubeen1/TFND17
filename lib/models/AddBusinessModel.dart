class AddBusinessModel {
  String? name;
  String? category;
  String? description;
  String? discount;
  String? image;
  String? date;
  int? clickCount;
  int? uid;
  String? counter;
  String? email;

  AddBusinessModel({
    this.counter,
    this.category,
    this.name,
    this.email,
    this.description,
    this.discount,
    this.image,
    this.date,
    this.uid,
    this.clickCount = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      "category": category,
      "counter":counter,
      "email": email,
      "name": name,
      "clickCount": clickCount,
      "description": description,
      "discount": discount,
      "image": image,
      "date": date,
      "uid": uid,
    };
  }

  factory AddBusinessModel.fromJson(Map<String, dynamic> json) {
    return AddBusinessModel(
      category: json["category"] ?? "",
      counter: json["counter"]??"",
      email: json["email"] ?? '',
      name: json["name"] ?? "",
      description: json["description"] ?? "",
      discount: json["discount"] ?? "",
      image: json["image"] ?? "",
      date: json["date"] ?? "",
      uid: json["uid"] ?? "",
      clickCount: json["clickCount"] ?? 0,
    );
  }
}
