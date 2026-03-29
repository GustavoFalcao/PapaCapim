import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/logo_clickable.dart';

class EditProfileScreen extends StatefulWidget {
  final String login;
  const EditProfileScreen({super.key, required this.login});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController nome = TextEditingController();
  final TextEditingController senha = TextEditingController();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: LogoClickable(login: widget.login, context: context),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: nome, decoration: const InputDecoration(labelText: "Novo Nome", border: OutlineInputBorder())),
            const SizedBox(height: 20),
            TextField(controller: senha, obscureText: true, decoration: const InputDecoration(labelText: "Nova Senha", border: OutlineInputBorder())),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: loading ? null : () async {
                setState(() => loading = true);
                final ok = await ApiService.updateProfile(ApiService.currentUserId ?? 0, nome.text, senha.text);
                setState(() => loading = false);
                if (ok) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: const Size(double.infinity, 50)),
              child: loading ? const CircularProgressIndicator(color: Colors.white) : const Text("Salvar", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}