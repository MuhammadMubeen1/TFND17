import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tfnd_app/models/AddBusinessModel.dart';

class BusinessController extends ChangeNotifier {
  List<AddBusinessModel> businesses = [];
  List<AddBusinessModel> filteredBusinesses = [];
  List<String> allCategories = ["All"];
  String? selectedCategory = "All";
  TextEditingController _searchController = TextEditingController();

  BusinessController() {
    _initializeController();
  }

  TextEditingController get searchController => _searchController;

  void _initializeController() {
    _fetchCategories();
    _listenToBusinessChanges();
  }

  void _fetchCategories() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('BusinessCategory')
          .get();

      allCategories.addAll(querySnapshot.docs.map((doc) => doc["Category"]));
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  void _listenToBusinessChanges() {
    FirebaseFirestore.instance
        .collection("BusinessRegister")
        .orderBy(FieldPath.documentId, descending: true)
        .snapshots()
        .listen((snapshot) {
      businesses = snapshot.docs
          .map((doc) => AddBusinessModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      _applyFilters();
      notifyListeners();
    });
  }

  void _applyFilters() {
    if (selectedCategory != null && selectedCategory != "All") {
      filteredBusinesses = businesses.where((business) {
        final businessCategory = business.category?.toLowerCase() ?? '';
        return businessCategory.contains(selectedCategory!.toLowerCase());
      }).toList();
    } else {
      filteredBusinesses = List.from(businesses);
    }

    final searchQuery = _searchController.text.toLowerCase();
    if (searchQuery.isNotEmpty) {
      filteredBusinesses = filteredBusinesses.where((business) {
        final name = business.name?.toLowerCase() ?? '';
        return name.contains(searchQuery);
      }).toList();
    }
  }

  void filterBusinesses(String query) {
    _applyFilters();
    notifyListeners();
  }

  void filterBusinessesByCategory(String? category) {
    selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
