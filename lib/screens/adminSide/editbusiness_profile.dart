import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tfnd_app/themes/color.dart';

class Editbusinessprofile extends StatefulWidget {
  final String eamil, password, image;

  const Editbusinessprofile({
    Key? key,
    required this.eamil,
    required this.image,
    required this.password,
    // required this.i
  }) : super(key: key);

  @override
  State<Editbusinessprofile> createState() => _ProfileBarState();
}

class _ProfileBarState extends State<Editbusinessprofile> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;
  PickedFile? imageFile;
  String profilePicUrl = "";
  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.eamil.toString();
    _passwordController.text = widget.password;
    // profilePicUrl = widget.image;
  }


 void dispose() {
    _nameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  Future<String> uploadImageToStorage(String filePath) async {
    final Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('user_profile_pictures')
        .child('${DateTime.now().millisecondsSinceEpoch}');
    final UploadTask uploadTask = storageReference.putFile(File(filePath));
    final TaskSnapshot snapshot = await uploadTask;
    final String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.bgColor,
    
        centerTitle: true,
        title: const Text(
          "Edit Profile",
          style: TextStyle(
              color: AppColor.blackColor,
              fontSize: 20,
              fontWeight: FontWeight.w500),
        ),
        actions: [],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 15),
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: ((builder) => openGallery()),
                    );
                  },
                  child: Center(
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(600),
                          child: Container(
                            height: 140,
                            width: 140,
                            child: (imageFile != null)
                                ? Image.file(
                                    File(imageFile!.path),
                                    fit: BoxFit.cover,
                                  )
                                : (widget.image.isEmpty
                                    ? Image.asset(
                                        'assets/images/tfndlog.jpg',
                                        fit: BoxFit.cover,
                                      )
                                    : Image.network(
                                        widget.image,
                                        fit: BoxFit.cover,
                                      )),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                builder: ((builder) => openGallery()),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: AppColor.btnColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                TextFormField(
                     readOnly: true,
                                    controller: _emailController,
                  // Negate the visibility here
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: AppColor.hintColor,
                    ),
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
                fillColor: Colors.white,
               filled: true
                 ),
                ), 
               const  SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_passwordVisible, // Negate the visibility here

                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.password_rounded,
                      color: AppColor.btnColor,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: AppColor.btnColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
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
                  fillColor: Colors.white,
                  filled: true
                  ),
                ),

                const SizedBox(height: 20),
                Container(
                  child: ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColor.btnColor,
    textStyle: const TextStyle(fontSize: 18),
    minimumSize: const Size.fromHeight(50),
  ),
  onPressed: isLoading
      ? null // Disable button if loading
      : () async {
          setState(() {
            isLoading = true; // Set isLoading to true immediately
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColor.btnColor,
              content: Text('Please wait...!', style: TextStyle(color: Colors.black),),
            ),
          );
          if (imageFile != null) {
            await uploadProfilePicture();
          }
          updateUserProfile();
        },
  child: isLoading
      ?const  Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Colors.black,
            ),
            SizedBox(
              width: 24,
            ),
            Text(
              "Please Wait...",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        )
      : const Text(
          "Update Profile",
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
),


                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget openGallery() {
    return Container(
      height: 100.0,
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          const Text(
            "Choose profile photo",
            style: TextStyle( fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MaterialButton(
                onPressed: () {
                  takePhoto(ImageSource.camera);
                  Navigator.pop(context);
                },
                child: const Row(
                  children: [
                    Text("Camera "),
                    SizedBox(
                      width: 5,
                    ),
                    Icon(Icons.camera_alt, color: AppColor.btnColor,),
                  ],
                ),
              ),
              MaterialButton(
                onPressed: () {
                  takePhoto(ImageSource.gallery);
                  Navigator.pop(context);
                },
                child: const Row(
                  children: [
                    Text("Gallery ", ),
                    SizedBox(
                      width: 5,
                    ),
                    Icon(Icons.image, color: AppColor.btnColor,),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void takePhoto(ImageSource source) async {
    final pickedFile = await ImagePicker().getImage(source: source);
    if (pickedFile != null) {
      setState(() {
        imageFile = pickedFile;
      });
    }
  }

Future<void> uploadProfilePicture() async {
  try {
    if (imageFile != null) {
      String downloadUrl = await uploadImageToStorage(imageFile!.path);
      setState(() {
        profilePicUrl = downloadUrl;
      });
    }
  } catch (error) {
    print('Error uploading profile picture: $error');
    // Handle error as needed
  }
}


  Future<void> updateUserProfile() async {
  setState(() {
    isLoading = true;
  });

  try {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Admin')
        .where('email', isEqualTo: widget.eamil.toString())
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      Map<String, dynamic> dataToUpdate = {
        'email': _emailController.text.isEmpty || _emailController.text == null
            ? widget.eamil
            : _emailController.text,
        'password': _passwordController.text.isEmpty ||
            _passwordController.text == null
            ? widget.password
            : _passwordController.text,
      };

      if (imageFile != null) {
        String downloadUrl = await uploadImageToStorage(imageFile!.path);
        dataToUpdate['image'] = downloadUrl;
      }

      await doc.reference.update(dataToUpdate);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColor.btnColor,
          content: Text('Profile updated successfully!', style: TextStyle(color: Colors.black),),
        ),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColor.btnColor,
          content: Text('User not found!', style: TextStyle(color: Colors.black)),
        ),
      );
    }
  } catch (error) {
    print('Error updating profile: $error');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          backgroundColor: AppColor.btnColor,
        content: Text('Failed to update profile. Please try again.',style: TextStyle(color: Colors.black),
        ))
    );
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}

}
