import 'dart:io';

import 'package:fashion_roller/widget/bottom_navigation_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


class UserForm extends StatefulWidget {
  @override
  _UserFormState createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  File? _selectedImage;

  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _dobController = TextEditingController();
  TextEditingController _genderController = TextEditingController();
  TextEditingController _ageController = TextEditingController();
  List<String> gender = ["Male", "Female", "Other"];

  Future<void> _selectProfileImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  Future<void> _selectDateFromPicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(DateTime.now().year - 20),
      firstDate: DateTime(DateTime.now().year - 30),
      lastDate: DateTime(DateTime.now().year),
    );
    if (picked != null)
      setState(() {
        _dobController.text = "${picked.day}/ ${picked.month}/ ${picked.year}";
      });
  }

  Future<void> sendUserDataToDB() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    var currentUser = _auth.currentUser;

    CollectionReference _collectionRef =
    FirebaseFirestore.instance.collection("users-form-data");

    // Upload profile image to Firebase Storage
    if (_selectedImage != null) {
      String fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
      firebase_storage.Reference storageReference = firebase_storage
          .FirebaseStorage.instance
          .ref()
          .child("profile_images")
          .child(fileName);

      await storageReference.putFile(_selectedImage!);

      String downloadURL = await storageReference.getDownloadURL();

      // Save user data including profile image URL to Firestore
      await _collectionRef.doc(currentUser!.email).set({
        "name": _nameController.text,
        "phone": _phoneController.text,
        "dob": _dobController.text,
        "gender": _genderController.text,
        "age": _ageController.text,
        "profileImageURL": downloadURL, // Save the download URL in Firestore
      });

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BottomNavController()),
      );
    } else {
      // Handle the case when no profile image is selected
      print("Please select a profile image");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Submit the form to continue.",
                  style:
                      TextStyle(fontSize: 22, color: Colors.orangeAccent),
                ),
                Text(
                  "We will not share your information with anyone.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFFBBBBBB),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Center(
                  child: GestureDetector(
                    onTap: _selectProfileImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!) as ImageProvider<Object>
                          : AssetImage('assets/default_profile_image.jpg'), // Provide a default image
                      child: _selectedImage == null
                          ? Icon(
                        Icons.camera_alt,
                        size: 30,
                        color: Colors.white,
                      )
                          : null,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                TextField(
                  keyboardType: TextInputType.text,
                  controller: _nameController,
                  cursorColor: Colors.orangeAccent.shade400,
                  decoration: InputDecoration(
                    labelText: "Enter your name",
                    labelStyle: TextStyle(color: Colors.orangeAccent),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orangeAccent.shade400),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    hintText: 'Name',
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                TextField(
                  keyboardType: TextInputType.number,
                  controller: _phoneController,
                  cursorColor: Colors.orangeAccent.shade400,
                  decoration: InputDecoration(
                    labelStyle: TextStyle(color: Colors.orangeAccent),
                    labelText: "Enter your Phone number",
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orangeAccent.shade400),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    hintText: 'Phone Number',
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                TextField(
                  controller: _dobController,
                  readOnly: true,
                  cursorColor: Colors.orangeAccent.shade400,
                  decoration: InputDecoration(
                    labelText: "Date of Birth",
                    labelStyle: TextStyle(color: Colors.orangeAccent),
                    hintText: "Select your date of birth",
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orangeAccent.shade400),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    suffixIcon: IconButton(
                      onPressed: () => _selectDateFromPicker(context),
                      icon: Icon(
                        Icons.calendar_today_outlined,
                        color: Colors.orangeAccent,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                TextField(
                  controller: _genderController,
                  readOnly: true,
                  cursorColor: Colors.orangeAccent.shade400,
                  decoration: InputDecoration(
                    labelStyle: TextStyle(color: Colors.orangeAccent),
                    labelText: "Gender",
                    hintText: _genderController.text.isNotEmpty
                        ? _genderController.text
                        : "Choose your gender",
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orangeAccent.shade400),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    suffixIcon: DropdownButton<String>(
                      items: gender.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: new Text(value),
                          onTap: () {
                            setState(() {
                              _genderController.text = value;
                            });
                          },
                        );
                      }).toList(),
                      onChanged: (_) {},
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                TextField(
                  keyboardType: TextInputType.number,
                  controller: _ageController,
                  cursorColor: Colors.orangeAccent.shade400,
                  decoration: InputDecoration(
                    labelStyle: TextStyle(color: Colors.orangeAccent),
                    labelText: "Enter your age",
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orangeAccent.shade400),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    hintText: 'Age',
                  ),
                ),
                SizedBox(
                  height: 50,
                ),

               Center(
                 child: ElevatedButton(
                   style: ElevatedButton.styleFrom(
                     backgroundColor: Colors.orangeAccent, // Change the primary color to your desired color
                   ),
                   onPressed: sendUserDataToDB,
                   child: Text("Continue"),
                 ),
               )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

