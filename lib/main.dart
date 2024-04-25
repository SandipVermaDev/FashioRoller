import 'package:fashion_roller/screen/login_register_screen.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screen/splash_screen.dart';
import 'widget/bottom_navigation_bar.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FashionRoller',
      home: SplashScreen(),
    );
  }
}

class ChooseScreen extends StatelessWidget {
  const ChooseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthClass().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return BottomNavController();
        } else {
          return const LoginAndRegisterScreen();
        }
      },
    );
  }
}