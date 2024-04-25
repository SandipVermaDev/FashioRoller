import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'product_detail_screen.dart';

class ProductScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ProductGridView(),
    );
  }
}

class ProductGridView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('products').snapshots(),
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
            final productCategory = product['product-category'] as String;

            return GestureDetector(
              onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>ProductDetails(products[index]))),
              child: Card(
                elevation: 2.0,
                child: Column(
                  children: [
                    AspectRatio(
                        aspectRatio: 1.4,
                        child: Image.network(productImage)),
                    Text('$productName ($productCategory)'),
                    Text("Rs: "+productPrice+"/-"),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}