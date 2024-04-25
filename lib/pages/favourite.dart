import 'package:flutter/material.dart';

import '../widget/fetchProducts.dart';

class Favourite extends StatefulWidget {
  @override
  _FavouriteState createState() => _FavouriteState();
}

class _FavouriteState extends State<Favourite> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your favourites'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: SafeArea(
        child: fetchData("users-favourite-items"),
      ),
    );
  }
}
