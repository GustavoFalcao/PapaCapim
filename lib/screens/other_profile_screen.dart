import 'package:flutter/material.dart';
import '../services/api_service.dart';

class OtherProfileScreen extends StatefulWidget {
  final String login;
  final String profileLogin;
  const OtherProfileScreen({super.key, required this.login, required this.profileLogin});

  @override
  State<OtherProfileScreen> createState() => _OtherProfileScreenState();
}

class _OtherProfileScreenState extends State<OtherProfileScreen> {
  Map<String, dynamic>? usuario;
  List<dynamic> posts = [];
  List<dynamic> followers = [];
  bool isLoading = true;
  bool isFollowing = false;

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

Future<void> carregarDados() async {  
  setState(() => isLoading = true);
  
  final userData = await ApiService.getUsuario(widget.profileLogin);
  final userPosts = await ApiService.getUserPosts(widget.profileLogin);
  final userFollowers = await ApiService.getFollowers(widget.profileLogin);
  final following = await ApiService.isFollowing(widget.profileLogin);
  
  setState(() {
    usuario = userData;
    posts = userPosts;
    followers = userFollowers;
    isFollowing = following;
    isLoading = false;
  });
}

  void toggleFollow() async {
    setState(() => isFollowing = !isFollowing);
    
    if (isFollowing) {
      await ApiService.followUser(widget.profileLogin);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Você começou a seguir @${widget.profileLogin}")),
      );
    } else {
      await ApiService.unfollowUser(widget.profileLogin);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Você deixou de seguir @${widget.profileLogin}")),
      );
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (usuario == null) {
      return const Scaffold(
        body: Center(child: Text("Usuário não encontrado")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(usuario?['name'] ?? 'Perfil'),
        backgroundColor: Colors.green,
      ),
      body: RefreshIndicator(
  onRefresh: carregarDados,  
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
                      ],
                    ),
                    const SizedBox(height: 20),
                    // BOTÃO SEGUIR
                    if (widget.profileLogin != widget.login)
                      SizedBox(
                        width: 200,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isFollowing ? Colors.grey : Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: toggleFollow,
                          icon: Icon(
                            isFollowing ? Icons.person_remove : Icons.person_add,
                            color: Colors.white,
                          ),
                          label: Text(
                            isFollowing ? "Deixar de Seguir" : "Seguir",
                            style: const TextStyle(color: Colors.white),
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
                    "Postagens",
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
                              "Este usuário ainda não fez postagens",
                              style: TextStyle(color: Colors.grey),
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
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post['message'] ?? '',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.favorite,
                                          size: 14,
                                          color: Colors.red,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${post['curtidas']?.length ?? 0}',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      _formatDate(post['created_at']),
                                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                                    ),
                                  ],
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
}