import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PostScreen extends StatefulWidget {
  final String login;
  const PostScreen({super.key, required this.login});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final TextEditingController conteudoController = TextEditingController();
  bool isLoading = false;

  void publicarPost() async {
    if (conteudoController.text.isEmpty) return;

    setState(() => isLoading = true);

    final success = await ApiService.criarPost(widget.login, conteudoController.text);

    setState(() => isLoading = false);

    if (success != null) {
      Navigator.pop(context); // Volta para o feed
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro ao publicar postagem")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nova Postagem"), backgroundColor: Colors.green),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: conteudoController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: "O que você está pensando?",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : publicarPost,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Publicar"),
            ),
          ],
        ),
      ),
    );
  }
}