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
  int caracteresRestantes = 280;

  @override
  void initState() {
    super.initState();
    conteudoController.addListener(_atualizarContador);
  }

  @override
  void dispose() {
    conteudoController.removeListener(_atualizarContador);
    conteudoController.dispose();
    super.dispose();
  }

  void _atualizarContador() {
    setState(() {
      caracteresRestantes = 280 - conteudoController.text.length;
    });
  }

  void publicarPost() async {
    if (conteudoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Digite algo para publicar"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (conteudoController.text.length > 280) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("A postagem não pode ter mais de 280 caracteres"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    final success = await ApiService.criarPost(widget.login, conteudoController.text);

    setState(() => isLoading = false);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Postagem publicada com sucesso!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Retorna true para indicar sucesso
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Erro ao publicar postagem"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nova Postagem"),
        backgroundColor: Colors.green,
        actions: [
          TextButton(
            onPressed: isLoading ? null : publicarPost,
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    "Publicar",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar e informações do usuário
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.green,
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 25,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ApiService.currentUserLogin ?? widget.login,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Text(
                        "Publicar para todos",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Campo de texto
            TextField(
              controller: conteudoController,
              maxLines: 8,
              maxLength: 280,
              decoration: InputDecoration(
                hintText: "O que você está pensando?",
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.green, width: 2),
                ),
                counterText: '',
              ),
            ),
            // Contador de caracteres
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '$caracteresRestantes caracteres restantes',
                style: TextStyle(
                  fontSize: 12,
                  color: caracteresRestantes < 0
                      ? Colors.red
                      : caracteresRestantes < 50
                          ? Colors.orange
                          : Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Dicas
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb, color: Colors.green[700], size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Compartilhe o que você está pensando! "
                      "Outros usuários podem curtir e responder sua postagem.",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}