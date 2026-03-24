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
  final TextEditingController confirmarSenhaController = TextEditingController();
  bool isLoading = false;
  Map<String, dynamic>? usuarioAtual;

  @override
  void initState() {
    super.initState();
    carregarDadosAtuais();
  }

  void carregarDadosAtuais() async {
    final user = await ApiService.getUsuario(widget.login);
    setState(() {
      usuarioAtual = user;
      if (user != null) {
        nomeController.text = user['name'] ?? '';
      }
    });
  }

  void salvarPerfil() async {
    // Validações
    if (nomeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nome não pode estar vazio")),
      );
      return;
    }

    if (senhaController.text.isNotEmpty && 
        senhaController.text != confirmarSenhaController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("As senhas não coincidem")),
      );
      return;
    }

    setState(() => isLoading = true);

    final success = await ApiService.updateProfile(
      ApiService.currentUserId ?? 0,
      nomeController.text,
      senhaController.text,
    );

    setState(() => isLoading = false);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Perfil atualizado com sucesso!"),
            backgroundColor: Colors.green,
          ),
        );
        
        // Se a senha foi alterada, fazer logout
        if (senhaController.text.isNotEmpty) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text("Senha alterada"),
              content: const Text(
                "Sua senha foi alterada. Por favor, faça login novamente."
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    ApiService.token = null;
                    ApiService.currentUserLogin = null;
                    ApiService.currentUserId = null;
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/',
                      (route) => false,
                    );
                  },
                  child: const Text("OK"),
                ),
              ],
            ),
          );
        } else {
          Navigator.pop(context);
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Erro ao atualizar perfil"),
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
        title: const Text("Editar Perfil"),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.green,
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '@${widget.login}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // Campo Nome
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(
                labelText: "Nome",
                hintText: "Seu nome completo",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 20),
            // Campo Nova Senha
            TextField(
              controller: senhaController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Nova Senha",
                hintText: "Deixe em branco para manter a atual",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 20),
            // Campo Confirmar Senha
            TextField(
              controller: confirmarSenhaController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Confirmar Nova Senha",
                hintText: "Digite a nova senha novamente",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 30),
            // Botão Salvar
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: isLoading ? null : salvarPerfil,
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Text(
                        "Salvar Alterações",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            // Informação
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Se você alterar sua senha, precisará fazer login novamente.",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange[800],
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