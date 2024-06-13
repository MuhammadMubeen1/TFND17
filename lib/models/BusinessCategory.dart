class BusinessList {
  String? Category;

  BusinessList({
    this.Category,
  });

  Map<String, dynamic> toJson() {
    return {
      "Category": Category,
    };
  }

  factory BusinessList.fromJson(Map<String, dynamic> json) {
    return BusinessList(
      Category: json["Category"] ?? "",
    );
  }
}
