import 'package:flutter/material.dart';
import '../services/api_service.dart';

class EditProfileScreen extends StatefulWidget {
  final String login;
  const EditProfileScreen({super.key, required this.login});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  bool isLoading = false;

  void salvarPerfil() async {
    setState(() => isLoading = true);

    final success = await ApiService.updateProfile(
      ApiService.currentUserId ?? 0,
      nomeController.text,
      senhaController.text,
    );

    setState(() => isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Perfil atualizado com sucesso!")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro ao atualizar perfil")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // Aqui você poderia buscar os dados atuais do usuário
    // nomeController.text = ...
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Editar Perfil"), backgroundColor: Colors.green),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(labelText: "Novo Nome"),
            ),
            TextField(
              controller: senhaController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Nova Senha"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : salvarPerfil,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Salvar"),
            ),
          ],
        ),
      ),
    );
  }
}