import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/logo_clickable.dart';

class PostScreen extends StatefulWidget {
  final String login;
  const PostScreen({super.key, required this.login});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final TextEditingController controller = TextEditingController();
  bool isLoading = false;

  void publicar() async {
    if (controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Digite algo")));
      return;
    }
    setState(() => isLoading = true);
    final success = await ApiService.criarPost(widget.login, controller.text);
    setState(() => isLoading = false);
    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erro ao publicar")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: LogoClickable(login: widget.login, context: context),
        backgroundColor: Colors.green,
        actions: [
          TextButton(
            onPressed: isLoading ? null : publicar,
            child: isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white)) : const Text("Publicar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: controller,
              maxLines: 8,
              decoration: const InputDecoration(hintText: "O que você está pensando?", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  Icon(Icons.lightbulb, color: Colors.green[700]),
                  const SizedBox(width: 10),
                  const Expanded(child: Text("Compartilhe o que você está pensando!")),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}