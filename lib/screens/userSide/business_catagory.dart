import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tfnd_app/themes/color.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final TextEditingController _categoryController = TextEditingController();
  bool _isLoading = false;

  void _submitCategory(String category) {
    setState(() {
      _isLoading = true;
    });
    // Add category to Firebase collection
    FirebaseFirestore.instance.collection('BusinessCategory').add({
      'Category': category,
    }).then((_) {
      // Success message or any additional logic
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColor.blackColor,
          content: Text(
            'Category added successfully',
            style: TextStyle(color: AppColor.btnColor),
          ),
        ),
      );
    }).catchError((error) {
      // Error handling
      ScaffoldMessenger.of(
        
        context).showSnackBar(
        
        
        SnackBar(
            backgroundColor: AppColor.blackColor,
          content: Text('Failed to add category: $error',
          style: TextStyle(color: AppColor.btnColor),
        
        )
        
        ),
      );
    }).whenComplete(() {
      setState(() {
        _isLoading = false;
      });
    });
  }

  void _deleteCategory(String categoryId) {
    // Delete category from Firebase collection
    FirebaseFirestore.instance
        .collection('BusinessCategory')
        .doc(categoryId)
        .delete()
        .then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColor.btnColor,
          content: Text(
            'Category deleted successfully',
            style: TextStyle(color: Colors.black),
          ),
        ),
      );
    }).catchError((error) {
      // Error handling
      ScaffoldMessenger.of(context).showSnackBar(
        
        SnackBar(      backgroundColor: AppColor.btnColor,
          content: Text('Failed to delete category: $error',  style: TextStyle(color: Colors.black))),
      );
    });
  }

  void _updateCategory(String categoryId, String updatedCategory) {
    // Update category in Firebase collection
    FirebaseFirestore.instance
        .collection('BusinessCategory')
        .doc(categoryId)
        .update({'Category': updatedCategory}).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColor.btnColor,
          content: Text(
            'Category updated successfully',
            style: TextStyle(color: Colors.black),
          ),
        ),
      );
    }).catchError((error) {
      // Error handling
      ScaffoldMessenger.of(context).showSnackBar(
       
        SnackBar(
          backgroundColor: AppColor.btnColor,
          
          content: Text('Failed to update category: $error',    style: TextStyle(color: Colors.black)),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColor.bgColor,
        title: const Text(
          'Add Category',
          style: TextStyle(fontSize: 20, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _categoryController,
              decoration: InputDecoration(
                  hintText: 'Category',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  filled: true,
                  fillColor: Colors.white),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      String category = _categoryController.text.trim();
                      if (category.isNotEmpty) {
                        _submitCategory(category);
                        _categoryController.clear();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: AppColor.blackColor,
                            content: Text(
                              'Please enter a category',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.btnColor,
                padding: EdgeInsets.symmetric(vertical: 10.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.black)
                  : const Text(
                      'Submit',
                      style: TextStyle(fontSize: 20, color: Colors.black),
                    ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('BusinessCategory')
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Something went wrong'),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  // Extract categories from snapshot and sort them alphabetically
                  List<DocumentSnapshot> categories = snapshot.data!.docs;
                  categories
                      .sort((a, b) => a['Category'].compareTo(b['Category']));

                  return Container(
                    child: ListView.builder(
                      itemCount: categories.length,
                      itemBuilder: (BuildContext context, int index) {
                        DocumentSnapshot category = categories[index];
                        return Column(
                          children: [
                            ListTile(
                              title: Text(category['Category']),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          String updatedCategory =
                                              category['Category'];
                                          return AlertDialog(
                                            title: Text("Edit Category", style: TextStyle(color: AppColor.btnColor ),),
                                            content: TextField(
                                              onChanged: (newValue) {
                                                updatedCategory = newValue;
                                              },
                                              controller: TextEditingController(
                                                  text: updatedCategory),
                                              decoration: const InputDecoration(
                                                hintText:
                                                    "Enter updated category",
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text("Cancel", style: TextStyle(color: AppColor.btnColor, fontWeight: FontWeight.bold)),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  _updateCategory(category.id,
                                                      updatedCategory);
                                                  Navigator.pop(context);
                                                },
                                                child: Text("Save",  style: TextStyle(color: AppColor.blackColor, fontWeight: FontWeight.bold),),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title:
                                                const Text("Confirm Deletion", style: TextStyle(color: AppColor.btnColor),),
                                            content: const Text(
                                                "Are you sure you want to delete this category?"),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text("Cancel", style: TextStyle(color: AppColor.btnColor, fontWeight: FontWeight.bold),),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  _deleteCategory(category.id);
                                                  Navigator.pop(context);
                                                },
                                                child: Text("Delete",style: TextStyle(color: AppColor.blackColor,fontWeight: FontWeight.bold )),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Divider(), // Add a Divider between categories
                          ],
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }
}
