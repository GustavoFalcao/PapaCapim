import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String login;
  const ProfileScreen({super.key, required this.login});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? usuario;
  List<dynamic> posts = [];
  List<dynamic> followers = [];
  List<dynamic> following = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    carregarPerfil();
  }

Future<void> carregarPerfil() async {  // <-- MUDE void para Future<void>
  setState(() => isLoading = true);
  
  final dados = await ApiService.getUsuario(widget.login);
  final userPosts = await ApiService.getUserPosts(widget.login);
  final userFollowers = await ApiService.getFollowers(widget.login);
  final userFollowing = await ApiService.getFollowing(widget.login);
  
  setState(() {
    usuario = dados;
    posts = userPosts;
    followers = userFollowers;
    following = userFollowing;
    isLoading = false;
  });
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
                // Limpar dados e voltar ao login
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
              // Como não temos o ID da sessão, apenas limpamos os dados localmente
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Meu Perfil"),
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
              // CABEÇALHO DO PERFIL
              Container(
                color: Colors.green[50],
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.green,
                      child: const Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      usuario?['name'] ?? '',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '@${usuario?['login'] ?? ''}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // ESTATÍSTICAS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatCard(
                          'Posts',
                          posts.length.toString(),
                          Icons.article,
                        ),
                        _buildStatCard(
                          'Seguidores',
                          followers.length.toString(),
                          Icons.people,
                        ),
                        _buildStatCard(
                          'Seguindo',
                          following.length.toString(),
                          Icons.person_add,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // BOTÕES DE AÇÃO
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, '/edit_profile');
                        },
                        icon: const Icon(Icons.edit, color: Colors.white),
                        label: const Text(
                          "Editar Perfil",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
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
              // POSTAGENS DO USUÁRIO
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
                                Icon(
                                  Icons.favorite,
                                  size: 16,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${post['curtidas']?.length ?? 0}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            onTap: () {
                              // Mostrar post completo (opcional)
                            },
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

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
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
          Icon(icon, size: 24, color: Colors.green),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
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
}