import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'add_product.dart';
import 'update_product.dart';

class ManageProducts extends StatefulWidget {
  const ManageProducts({super.key});

  @override
  _ManageProductsState createState() => _ManageProductsState();
}

class _ManageProductsState extends State<ManageProducts> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Products'),
        backgroundColor: Colors.orangeAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddProductScreen(), // Create this screen
                ),
              );
            },
          ),
        ],
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final products = snapshot.data!.docs;

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index].data() as Map<String, dynamic>;
              final productId = products[index].id;

              return ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailScreen(
                        productId: productId,
                      ),
                    ),
                  );
                },
                leading: Image.network(
                  product['product-img'],
                  width: 50,
                  height: 80,
                  fit: BoxFit.cover,
                ),
                title: Text(product['product-name']),
                subtitle: Text("Rs : ${product['product-price']}/-"),
              );
            },
          );
        },
      ),
    );
  }
}

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key,
    required this.productId,
  });

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}


class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Map<String, dynamic>? productData;

  @override
  void initState() {
    super.initState();
    fetchProductDetails();
  }

  Future<void> fetchProductDetails() async {
    try {
      DocumentSnapshot productSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .get();

      if (mounted) {
        setState(() {
          productData = productSnapshot.data() as Map<String, dynamic>;
        });
      }
    } catch (error) {
      print('Error fetching product details: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: productData == null
          ? const Center(
        child: CircularProgressIndicator(),
      )
      :Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.network(
            productData!['product-img'],
            width: 400,
            height: 400,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 20),
          Text(
            productData!['product-name'],
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Rs: ${productData!['product-price']}/-",
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Quantity: ${productData!['product-quantity'] ?? 'N/A'}",
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Category: ${productData!['product-category'] ?? 'N/A'}",
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UpdateProductScreen(
                        productId: widget.productId,
                        productData: productData,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Update'),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: () async {
                  bool confirmDelete = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Confirm Delete'),
                        content: const Text('Are you sure you want to delete this product?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(false); // Not deleting
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(true); // Confirm deleting
                            },
                            child: const Text('Delete'),
                          ),
                        ],
                      );
                    },
                  );

                  if (confirmDelete == true) {
                    await FirebaseFirestore.instance
                        .collection('products')
                        .doc(widget.productId)
                        .delete();
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
