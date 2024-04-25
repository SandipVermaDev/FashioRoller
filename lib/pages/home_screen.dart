import 'package:flutter/material.dart';

import '../screen/CategoryProductScreen.dart';
import '../screen/ProductScreen.dart';
import '../screen/search_screen.dart';
import '../widget/carousel_slider.dart';
import '../widget/drawer.dart';


class home_screen extends StatefulWidget {
  const home_screen({Key? key}) : super(key: key);

  @override
  State<home_screen> createState() => _home_screenState();
}

class _home_screenState extends State<home_screen> {
  final List<String> categories = ['Men', 'Women', 'Unisex', 'Kids'];

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      drawer: Drawer(
        child: AppDrawer(),
      ),
      body: Column(
        children: [
          SafeArea(
            child: AppBar(
              actions: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.search,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SearchScreen()),
                    );
                  },
                ),
              ],
              flexibleSpace: CarouselSliderWidget(),
              backgroundColor: Colors.white30,
              iconTheme: IconThemeData(color: Colors.orangeAccent),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Container(
            height: 60, // Adjust the height as needed
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                    onTap: () {
                  // Navigate to a new page displaying products of the selected category
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryProductScreen(
                        category: categories[index],
                      ),
                    ),
                  );
                },
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.orangeAccent,
                      ),
                      child: Text(
                        categories[index],
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      categories[index],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                );
              },
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: ProductScreen(),
          ),
        ],
      ),
    );
  }
}