import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_roller/admin/manage_products.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class UpdateProductScreen extends StatefulWidget {
  final String productId;
  final Map<String, dynamic>? productData;

  UpdateProductScreen({
    required this.productId,
    required this.productData,
  });

  @override
  _UpdateProductScreenState createState() => _UpdateProductScreenState();
}

class _UpdateProductScreenState extends State<UpdateProductScreen> {
  File? _image;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  String _selectedCategory = 'Men';


  @override
  void initState() {
    super.initState();
    _nameController.text = widget.productData?['product-name'] ?? '';
    _descriptionController.text = widget.productData?['product-description'] ?? '';
    _priceController.text = (widget.productData?['product-price'] ?? 0).toString();
    _quantityController.text = (widget.productData?['product-quantity'] ?? 0).toString();
    _selectedCategory = widget.productData?['product-category'] ?? 'Men';
  }

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
      String updatedName = _nameController.text;
      String updatedDescription = _descriptionController.text;
      double updatedPrice = double.parse(_priceController.text);
      int updatedQuantity = int.parse(_quantityController.text);

      Map<String, dynamic> updatedData = {
        'product-name': updatedName,
        'product-description': updatedDescription,
        'product-price': updatedPrice,
        'product-quantity': updatedQuantity,
        'product-category': _selectedCategory,
      };

      if (_image != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('product_images/${DateTime.now()}.jpg');
        await storageRef.putFile(_image!);
        final imageUrl = await storageRef.getDownloadURL();

        updatedData['product-img'] = imageUrl;
      }


      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .update(updatedData);

      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailScreen(
            productId: widget.productId,
          ),
        ),
      );
    } catch (error) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('An error occurred while updating the product.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Product'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Text fields for updating product information
              Text("Old Image"),
              Image.network(
                widget.productData?['product-img'], // Use the updated URL
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),

              Text("New Image"),
              if (_image != null)
                Image.file(
                  _image!,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              InkWell(
                onTap: () => _pickImage(),
                child: Container(
                  width: 200,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image,
                          color: Colors.white,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Select New Image',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Product Name'),
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Product Description'),
              ),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Product Price'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(labelText: 'Product Quantity'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              SizedBox(height: 20),

              // Display the selected category with a label
              Row(
                children: [
                  Text(
                    'Category: ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _selectedCategory,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),

              // Dropdown list for selecting the category
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                icon: const Icon(Icons.arrow_downward),
                iconSize: 24,
                elevation: 16,
                style: const TextStyle(color: Colors.deepPurple),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
                items: <String>['Men', 'Women', 'Unisex', 'Kids']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveProduct,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
