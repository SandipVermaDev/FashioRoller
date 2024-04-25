import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  File? _image;
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  String selectedCategory = 'Men';

  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }


  Future<void> saveProduct() async {
    try {
      if (_image != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('product_images/${DateTime.now()}.jpg');
        await storageRef.putFile(_image!);
        final imageUrl = await storageRef.getDownloadURL();

        await FirebaseFirestore.instance.collection('products').add({
          'product-img': imageUrl,
          'product-name': nameController.text,
          'product-description': descriptionController.text,
          'product-price': priceController.text,
          'product-quantity': quantityController.text,
          'product-category': selectedCategory,
        });
        Navigator.pop(context);
      } else {
        print('Please select an image.');
      }
    } catch (e) {
      print('Error adding product: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (_image != null)
                SizedBox(
                  width: 450,
                  height: 500,
                  child: Image.file(_image!, fit: BoxFit.cover),
                ),
              InkWell(
                onTap: () => _pickImage(),
                child: Container(
                  width: 200, // Set your desired width
                  height: 50,  // Set your desired height
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent, // Change the button background color
                    borderRadius: BorderRadius.circular(10.0), // Add rounded corners
                  ),
                  child: const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image, // You can use any icon from the Icons library
                          color: Colors.white, // Change the icon color
                        ),
                        SizedBox(width: 10), // Add spacing between icon and text
                        Text(
                          'Select Product Image',
                          style: TextStyle(
                            color: Colors.white, // Change the text color
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Product Description'),
              ),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(labelText: 'Product Price'),
              ),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(labelText: 'Product Quantity'),
              ),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: ['Men', 'Women', 'Unisex', 'Kids'].map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    selectedCategory = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Product Category'),
              ),
              ElevatedButton(
                onPressed: saveProduct,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}