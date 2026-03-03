import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart'; 
import 'screens/profile_screen.dart'; 
import 'screens/edit_profile_screen.dart';
import 'screens/post_screen.dart'; 
import 'screens/feed_screen.dart';

void main() {
  runApp(const PapacapimApp());
}

class PapacapimApp extends StatelessWidget {
  const PapacapimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Papacapim',
      theme: ThemeData(primarySwatch: Colors.green),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        // Profile, EditProfile e Post serão abertos via MaterialPageRoute passando userId
      },
    );
  }
}