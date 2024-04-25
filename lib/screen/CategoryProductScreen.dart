import 'package:fashion_roller/screen/product_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryProductScreen extends StatelessWidget {
  final String category;

  CategoryProductScreen({required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$category Products'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .where('product-category', isEqualTo: category)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading products'),
            );
          }

          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          final products = snapshot.data!.docs;

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10.0,
              crossAxisSpacing: 12.0,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              final productName = product['product-name'] as String;
              final productImage = product['product-img'] as String;
              final productPrice = product['product-price'].toString();

              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetails(product),
                  ),
                ),
                child: Card(
                  elevation: 2.0,
                  child: Column(
                    children: [
                      AspectRatio(
                        aspectRatio: 1.3,
                        child: Image.network(productImage),
                      ),
                      Text(productName),
                      Text("Rs: " + productPrice + "/-"),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
