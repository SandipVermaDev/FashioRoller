import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

void showImageDialog(BuildContext context, String collectionName, String collectionId) {
  FirebaseFirestore.instance
      .collection(collectionName)
      .doc(FirebaseAuth.instance.currentUser!.email)
      .collection("items")
      .doc(collectionId)
      .get()
      .then((DocumentSnapshot documentSnapshot) {
    if (documentSnapshot.exists) {
      String imageUrl = documentSnapshot['images'];
      String productName = documentSnapshot['name'];
      double productPrice = documentSnapshot['price'] ?? 0.0;

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.network(
                  imageUrl,
                  width: 200, // Adjust the width as needed
                  height: 300, // Adjust the height as needed
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 10),
                Text(
                  productName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Rs. ${productPrice.toStringAsFixed(2)}', // Displaying price with 2 decimal places
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Add your order logic here
                  // For example, you can call a function to handle the order
                  handleOrder(productName, productPrice);
                  Navigator.pop(context); // Close the dialog after placing the order
                },
                child: Text('Order'),
              ),
            ],
          );
        },
      );
    } else {
      // Handle the case when the document does not exist
      print('Document does not exist');
    }
  }).catchError((error) {
    // Handle errors
    print('Error: $error');
  });
}

void handleOrder(String productName, double productPrice) {
  // Add your order handling logic here
  // For example, you can send the order details to a backend server
  print('Order placed for $productName. Total cost: \$${productPrice.toStringAsFixed(2)}');
}