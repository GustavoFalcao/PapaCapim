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
  String? errorMessage;

  String get _loginCorreto => ApiService.currentUserLogin ?? widget.login;

  @override
  void initState() {
    super.initState();
    carregarPerfil();
  }

  Future<void> carregarPerfil() async {
    final loginParaBuscar = _loginCorreto;
    
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    
    try {
      final dados = await ApiService.getUsuario(loginParaBuscar);
      
      if (dados == null) {
        setState(() {
          errorMessage = "Usuário não encontrado: $loginParaBuscar";
          isLoading = false;
        });
        return;
      }
      
      final userPosts = await ApiService.getUserPosts(loginParaBuscar);
      
      setState(() {
        usuario = dados;
        posts = userPosts;
        isLoading = false;
      });
      
    } catch (e) {
      print("Erro ao carregar perfil: $e");
      setState(() {
        errorMessage = "Erro ao carregar perfil: $e";
        isLoading = false;
      });
    }
  }

  Future<void> _deletePostFromProfile(int postId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Excluir postagem"),
        content: const Text("Tem certeza que deseja excluir esta postagem?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Excluir", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      await ApiService.deletePost(postId);
      carregarPerfil();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Postagem excluída com sucesso")),
        );
      }
    }
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Excluir Conta"),
        content: const Text(
          "Tem certeza? Esta ação é irreversível!\n\n"
          "Todos os seus posts, curtidas e seguidores serão perdidos.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ApiService.deleteAccount(
                ApiService.currentUserId ?? 0
              );
              if (success) {
                ApiService.token = null;
                ApiService.currentUserLogin = null;
                ApiService.currentUserId = null;
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Conta excluída com sucesso")),
                  );
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Erro ao excluir conta")),
                  );
                }
              }
            },
            child: const Text("Excluir", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Sair"),
        content: const Text("Tem certeza que deseja sair?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () async {
              ApiService.token = null;
              ApiService.currentUserLogin = null;
              ApiService.currentUserId = null;
              
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text("Sair", style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);
      
      if (diff.inDays > 7) {
        return '${date.day}/${date.month}/${date.year}';
      } else if (diff.inDays > 0) {
        return '${diff.inDays}d atrás';
      } else if (diff.inHours > 0) {
        return '${diff.inHours}h atrás';
      } else if (diff.inMinutes > 0) {
        return '${diff.inMinutes}m atrás';
      } else {
        return 'agora';
      }
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: LogoClickable(
            login: _loginCorreto,
            context: context,
          ),
          backgroundColor: Colors.green,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null || usuario == null) {
      return Scaffold(
        appBar: AppBar(
          title: LogoClickable(
            login: _loginCorreto,
            context: context,
          ),
          backgroundColor: Colors.green,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                errorMessage ?? "Erro ao carregar perfil",
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: carregarPerfil,
                child: const Text("Tentar novamente"),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: LogoClickable(
          login: _loginCorreto,
          context: context,
        ),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: "Sair",
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: carregarPerfil,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Container(
                color: Colors.green[50],
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.green,
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      usuario?['name'] ?? _loginCorreto,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '@${usuario?['login'] ?? _loginCorreto}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 3,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.article, size: 24, color: Colors.green),
                              const SizedBox(height: 5),
                              Text(
                                posts.length.toString(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                "Posts",
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
                    SizedBox(
                      width: 200,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfileScreen(login: _loginCorreto),
                            ),
                          ).then((_) => carregarPerfil());
                        },
                        icon: const Icon(Icons.edit, color: Colors.white),
                        label: const Text(
                          "Editar Perfil",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 200,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: _confirmDeleteAccount,
                        icon: const Icon(Icons.delete_forever, color: Colors.white),
                        label: const Text(
                          "Excluir Conta",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Minhas Postagens",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              posts.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.post_add, size: 48, color: Colors.grey),
                            SizedBox(height: 10),
                            Text(
                              "Você ainda não fez nenhuma postagem",
                              style: TextStyle(color: Colors.grey),
                            ),
                            Text(
                              "Clique no botão + para criar uma",
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          child: ListTile(
                            leading: const Icon(Icons.message, color: Colors.green),
                            title: Text(
                              post['message'] ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              _formatDate(post['created_at']),
                              style: const TextStyle(fontSize: 10),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.favorite,
                                  size: 16,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${post['curtidas']?.length ?? 0}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(width: 12),
                                IconButton(
                                  icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                                  onPressed: () => _deletePostFromProfile(post['id']),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}