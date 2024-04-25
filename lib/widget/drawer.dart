import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_roller/auth/firebase_auth.dart';
import 'package:fashion_roller/main.dart';
import 'package:fashion_roller/pages/cart.dart';
import 'package:fashion_roller/pages/favourite.dart';
import 'package:fashion_roller/pages/profile.dart';
import 'package:fashion_roller/screen/search_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../pages/orders.dart';



class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Column(
        children: [
          StreamBuilder<User?>(
          stream: AuthClass().authStateChanges,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else {
              User? user = snapshot.data;

              if (user != null) {
                return UserAccountsDrawerHeader(
                  accountName: FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users-form-data')
                        .doc(user.email)
                        .get(),
                    builder: (BuildContext context,
                        AsyncSnapshot<DocumentSnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text("Loading...");
                      } else {
                        return Text(snapshot.data?.get('name') ?? "User Name");
                      }
                    },
                  ),
                  accountEmail: Text(user.email ?? "Email"),
                  currentAccountPicture: FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users-form-data')
                        .doc(user.email)
                        .get(),
                    builder: (BuildContext context,
                        AsyncSnapshot<DocumentSnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else {
                        return CircleAvatar(
                          backgroundImage: NetworkImage(
                            snapshot.data?.get('profileImageURL') ??
                                "Default Image URL",
                          ),
                        );
                      }
                    },
                  ),
                );
              } else {
                return Container(); // Handle the case where the user is null
              }
            }
          },
        ),
        Expanded(
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.home, color: Colors.orangeAccent),
                title: Text('Home'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.search, color: Colors.orangeAccent),
                title: Text('Search'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SearchScreen()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.favorite, color: Colors.orangeAccent),
                title: Text('Favourite'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Favourite()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.shopping_cart, color: Colors.orangeAccent),
                title: Text('My Cart'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Cart()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.shopping_bag, color: Colors.orangeAccent),
                title: Text('Orders'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Orders()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.person, color: Colors.orangeAccent),
                title: Text('Profile'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Profile()),
                  );
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.settings, color: Colors.orangeAccent),
                title: Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/settings');
                },
              ),
              ListTile(
                leading: Icon(Icons.exit_to_app, color: Colors.orangeAccent),
                title: Text('Logout'),
                onTap: () async {
                  try {
                    await AuthClass().auth.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => ChooseScreen()),
                    ); // Navigate to the login screen
                  } catch (e) {
                    print("Error logging out: $e");
                  }
                },
              ),
            ],
          ),
        ),
        ],
        ),
    );
  }
}