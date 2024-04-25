import 'dart:io';


import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  File? _selectedImage;

  final CollectionReference _collectionRef =
  FirebaseFirestore.instance.collection("users-form-data");

  String? _profileImageURL;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _dobController;
  late TextEditingController _genderController;
  late TextEditingController _ageController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _dobController = TextEditingController();
    _genderController = TextEditingController();
    _ageController = TextEditingController();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _genderController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  _loadUserData() async {
    final doc = await _collectionRef
        .doc(FirebaseAuth.instance.currentUser!.email)
        .get();

    if (doc.exists) {
      setState(() {
        _profileImageURL = doc['profileImageURL'] ?? '';
        _nameController.text = doc['name'];
        _phoneController.text = doc['phone'];
        _dobController.text = doc['dob'];
        _genderController.text = doc['gender'];
        _ageController.text = doc['age'];
      });
    }
  }

  Future<void> _updateData() async {
    if (_selectedImage != null) {
      String imageURL = await uploadImageToStorage(_selectedImage!);
      setState(() {
        _profileImageURL = imageURL;
      });
    }

    await _collectionRef
        .doc(FirebaseAuth.instance.currentUser!.email)
        .update({
      "name": _nameController.text,
      "phone": _phoneController.text,
      "dob": _dobController.text,
      "gender": _genderController.text,
      "age": _ageController.text,
      "profileImageURL": _profileImageURL,
    });
    print("Updated Successfully");
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.orangeAccent,
            hintColor: Colors.orangeAccent,
            colorScheme: ColorScheme.light(primary: Colors.orangeAccent),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != DateTime.now()) {
      setState(() {
        _dobController.text = pickedDate.toString().split(' ')[0];
      });
    }
  }

  Future<void> _selectProfileImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      String imageURL = await compressAndUpload(File(pickedImage.path));
      setState(() {
        _profileImageURL = imageURL;
      });
    }
  }

  Future<String> compressAndUpload(File imageFile) async {
    try {
      img.Image image = img.decodeImage(imageFile.readAsBytesSync())!;
      img.Image resized = img.copyResize(image, width: 800); // Adjust the width as needed

      // Convert to bytes
      List<int> compressedBytes = img.encodeJpg(resized, quality: 85);

      final FirebaseAuth _auth = FirebaseAuth.instance;
      var currentUser = _auth.currentUser;

      final storage = firebase_storage.FirebaseStorage.instance;
      final ref = storage.ref().child('profile_images/${currentUser!.email}');
      await ref.putData(Uint8List.fromList(compressedBytes));

      return await ref.getDownloadURL();
    } catch (e) {
      print("Error compressing and uploading image: $e");
      return '';
    }
  }

  Future<String> uploadImageToStorage(File imageFile) async {
    try {
      if (!imageFile.existsSync()) {
        print("Error: The selected image file does not exist.");
        return '';
      }

      final FirebaseAuth _auth = FirebaseAuth.instance;
      var currentUser = _auth.currentUser;

      final storage = firebase_storage.FirebaseStorage.instance;
      final ref = storage.ref().child('profile_images/${currentUser!.email}');
      await ref.putFile(imageFile);

      return await ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      return '';
    }
  }


  Widget _buildForm(data) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 20),
          GestureDetector(
            onTap: _selectProfileImage,
            child: CircleAvatar(
              radius: 80,
              backgroundImage: _profileImageURL != null && _profileImageURL!.isNotEmpty
                  ? NetworkImage(_profileImageURL!) as ImageProvider<Object>
                  : AssetImage('assets/profile.png'),
            ),
          ),
          SizedBox(height: 30),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: "Name",
              labelStyle: TextStyle(color: Colors.orangeAccent),
            ),
          ),
          TextFormField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: "Phone Number",
              labelStyle: TextStyle(color: Colors.orangeAccent),
            ),
          ),
          TextFormField(
            onTap: () => _selectDate(context),
            controller: _dobController,
            readOnly: true,
            decoration: InputDecoration(
              labelText: "Date of Birth",
              labelStyle: TextStyle(color: Colors.orangeAccent),
            ),
          ),
          _buildGenderDropdown(),
          TextFormField(
            controller: _ageController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Age",
              labelStyle: TextStyle(color: Colors.orangeAccent),
            ),
          ),
          SizedBox(height: 50),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orangeAccent,
            ),
            onPressed: _updateData,
            child: Text("Update"),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _genderController.text.isEmpty ? null : _genderController.text,
      onChanged: (value) {
        setState(() {
          _genderController.text = value!;
        });
      },
      items: [
        DropdownMenuItem<String>(
          value: "Male",
          child: Text("Male"),
        ),
        DropdownMenuItem<String>(
          value: "Female",
          child: Text("Female"),
        ),
        DropdownMenuItem<String>(
          value: "Other",
          child: Text("Other"),
        ),
      ],
      decoration: InputDecoration(
        labelText: "Gender",
        labelStyle: TextStyle(color: Colors.orangeAccent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Profile'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: StreamBuilder(
            stream: _collectionRef
                .doc(FirebaseAuth.instance.currentUser!.email)
                .snapshots(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData) {
                return Center(child: Text('No data available.'));
              } else {
                return _buildForm(snapshot.data);
              }
            },
          ),
        ),
      ),
    );
  }
}
