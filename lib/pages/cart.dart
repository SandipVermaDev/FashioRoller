import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../widget/fetchProducts.dart';

class Cart extends StatefulWidget {
  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your cart'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: SafeArea(
        child: fetchData("users-cart-items"),
      ),
    );
  }
}
