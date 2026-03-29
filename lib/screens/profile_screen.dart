import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/logo_clickable.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String login;
  const ProfileScreen({super.key, required this.login});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? usuario;
  List<dynamic> posts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    carregarPerfil();
  }

  Future<void> carregarPerfil() async {
    setState(() => isLoading = true);
    usuario = await ApiService.getUsuario(widget.login);
    posts = await ApiService.getUserPosts(widget.login);
    if (!mounted) return;
    setState(() => isLoading = false);
  }

  void _excluirConta() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Excluir Conta"),
        content: const Text("Tem certeza? Esta ação é irreversível."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ApiService.deleteAccount(ApiService.currentUserId ?? 0);
              ApiService.token = null;
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
            child: const Text("Excluir", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: LogoClickable(login: widget.login, context: context), backgroundColor: Colors.green),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: LogoClickable(login: widget.login, context: context),
        backgroundColor: Colors.green,
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: () => ApiService.token = null)],
      ),
      body: RefreshIndicator(
        onRefresh: carregarPerfil,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              const CircleAvatar(radius: 50, backgroundColor: Colors.green, child: Icon(Icons.person, size: 50, color: Colors.white)),
              const SizedBox(height: 10),
              Text(usuario?['name'] ?? '', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text('@${usuario?['login'] ?? ''}', style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      children: [
                        const Icon(Icons.article, color: Colors.green),
                        Text(posts.length.toString(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const Text("Posts"),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EditProfileScreen(login: widget.login))),
                    icon: const Icon(Icons.edit, color: Colors.white),
                    label: const Text("Editar", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton.icon(
                    onPressed: _excluirConta,
                    icon: const Icon(Icons.delete, color: Colors.white),
                    label: const Text("Excluir", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text("Minhas Postagens", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: ListTile(
                      leading: const Icon(Icons.message, color: Colors.green),
                      title: Text(post['message'] ?? '', maxLines: 2),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.favorite, size: 16, color: Colors.red),
                          Text(' ${post['curtidas']?.length ?? 0}'),
                          IconButton(icon: const Icon(Icons.delete, size: 18, color: Colors.red), onPressed: () async {
                            await ApiService.deletePost(post['id']);
                            carregarPerfil();
                          }),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}