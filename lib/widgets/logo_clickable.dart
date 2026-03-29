import 'package:flutter/material.dart';
import '../screens/feed_screen.dart';

class LogoClickable extends StatelessWidget {
  final String login;
  final BuildContext context;

  const LogoClickable({
    super.key,
    required this.login,
    required this.context,
  });

  void _voltarParaHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => FeedScreen(login: login),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _voltarParaHome,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.flutter_dash, color: Colors.white, size: 28),
          const SizedBox(width: 8),
          const Text(
            "Papacapim",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}