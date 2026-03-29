import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/post_screen.dart';
import 'screens/feed_screen.dart';
import 'screens/search_screen.dart';
import 'screens/other_profile_screen.dart';

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
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/feed') {
          final login = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => FeedScreen(login: login),
          );
        }
        if (settings.name == '/profile') {
          final login = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => ProfileScreen(login: login),
          );
        }
        if (settings.name == '/edit_profile') {
          final login = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => EditProfileScreen(login: login),
          );
        }
        if (settings.name == '/post') {
          final login = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => PostScreen(login: login),
          );
        }
        if (settings.name == '/search') {
          final login = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => SearchScreen(login: login),
          );
        }
        if (settings.name == '/other_profile') {
          final args = settings.arguments as Map<String, String>;
          return MaterialPageRoute(
            builder: (context) => OtherProfileScreen(
              login: args['login']!,
              profileLogin: args['profileLogin']!,
            ),
          );
        }
        return null;
      },
    );
  }
}