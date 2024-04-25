import 'package:flutter/material.dart';

import '../main.dart';
import 'manage_products.dart';
import 'manage_users.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildAdminFunctionCard(
                    context,
                    'Manage Products',
                    Icons.shopping_basket,
                  ),
                  _buildAdminFunctionCard(
                    context,
                    'Manage Users',
                    Icons.person,
                  ),
                  _buildAdminFunctionCard(
                    context,
                    'Logout',
                    Icons.logout,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminFunctionCard(
      BuildContext context, String title, IconData icon) {
    Widget? destinationScreen;

    switch (title) {
      case 'Manage Products':
        destinationScreen = ManageProducts();
        break;
      case 'Manage Users':
        destinationScreen = ManageUsers();
        break;
      case 'Logout':
        destinationScreen = ChooseScreen();
        break;
      default:
    }
    return GestureDetector(
      onTap: () {
        if (destinationScreen != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => destinationScreen!),
          );
        }
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.orangeAccent.shade100,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.orangeAccent),
            SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
