import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'profile_screen.dart';
import 'edit_profile_screen.dart';
import 'post_screen.dart';
import 'search_screen.dart';
import 'other_profile_screen.dart';

class FeedScreen extends StatefulWidget {
  final String login;
  const FeedScreen({super.key, required this.login});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List<dynamic> posts = [];
  bool isLoading = true;
  bool isPosting = false;
  bool showOnlyFollowing = false;

  @override
  void initState() {
    super.initState();
    carregarFeed();
  }

  Future<void> carregarFeed() async {
    setState(() => isLoading = true);
    List<dynamic> dados;
    
    if (showOnlyFollowing) {
      dados = await ApiService.buscarFeedSeguindo(widget.login);
    } else {
      dados = await ApiService.buscarFeed(widget.login);
    }
    
    setState(() {
      posts = dados;
      isLoading = false;
    });
  }

  Future<void> criarPostagem(String conteudo) async {
    if (conteudo.trim().isEmpty) return;
    setState(() => isPosting = true);
    await ApiService.criarPost(widget.login, conteudo);
    setState(() => isPosting = false);
    carregarFeed();
  }

  Future<void> toggleLike(int postId) async {
    await ApiService.toggleLike(postId, widget.login);
    carregarFeed();
  }

  Future<void> replyPost(int postId, String conteudo) async {
    if (conteudo.trim().isEmpty) return;
    await ApiService.replyPost(postId, widget.login, conteudo);
    carregarFeed();
  }

  Future<void> deletePost(int postId) async {
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
      carregarFeed();
    }
  }

  void _showReplyDialog(int postId) {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Responder"),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: "Digite sua resposta...",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              replyPost(postId, controller.text);
            },
            child: const Text("Enviar"),
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
        return '${diff.inDays}d';
      } else if (diff.inHours > 0) {
        return '${diff.inHours}h';
      } else if (diff.inMinutes > 0) {
        return '${diff.inMinutes}m';
      } else {
        return 'agora';
      }
    } catch (e) {
      return '';
    }
  }

  Widget _buildReplies(int postId) {
    return FutureBuilder<List<dynamic>>(
      future: ApiService.getReplies(postId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }
        return Container(
          margin: const EdgeInsets.only(top: 10, left: 20),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: snapshot.data!.map((reply) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.subdirectory_arrow_right, size: 12, color: Colors.green),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            if (reply['user_login'] != widget.login) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OtherProfileScreen(
                                    login: widget.login,
                                    profileLogin: reply['user_login'],
                                  ),
                                ),
                              );
                            }
                          },
                          child: Text(
                            reply['user_login'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: reply['user_login'] == widget.login 
                                  ? Colors.green 
                                  : Colors.blue,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatDate(reply['created_at']),
                          style: const TextStyle(fontSize: 9, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(reply['message'] ?? ''),
                    const Divider(height: 8),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Papacapim"),
        backgroundColor: Colors.green,
        actions: [
          // Botão de filtrar feed
          IconButton(
            icon: Icon(
              showOnlyFollowing ? Icons.people : Icons.people_outline,
              color: showOnlyFollowing ? Colors.yellow : Colors.white,
            ),
            onPressed: () {
              setState(() {
                showOnlyFollowing = !showOnlyFollowing;
                carregarFeed();
              });
            },
            tooltip: showOnlyFollowing ? "Ver todos" : "Ver apenas quem sigo",
          ),
          // Botão de pesquisa
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchScreen(login: widget.login),
                ),
              );
            },
            tooltip: "Pesquisar",
          ),
          // Botão de perfil
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(login: widget.login),
                ),
              );
            },
            tooltip: "Meu perfil",
          ),
          // Botão de editar perfil
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfileScreen(login: widget.login),
                ),
              );
            },
            tooltip: "Editar perfil",
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: carregarFeed,
              child: posts.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.feed, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            "Nenhuma postagem ainda",
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            "Clique no botão + para criar uma",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        return Card(
                          margin: const EdgeInsets.all(10),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // CABEÇALHO DO POST - NOME DO USUÁRIO
                                Row(
                                  children: [
                                    const Icon(Icons.person, size: 20, color: Colors.green),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () {
                                        if (post['user_login'] != widget.login) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => OtherProfileScreen(
                                                login: widget.login,
                                                profileLogin: post['user_login'],
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      child: Text(
                                        post['user_login'] ?? 'Usuário desconhecido',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: post['user_login'] == widget.login 
                                              ? Colors.green 
                                              : Colors.blue,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      _formatDate(post['created_at']),
                                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // MENSAGEM
                                Text(
                                  post['message'] ?? '',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 10),
                                // BOTÕES DE AÇÃO
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    // CURTIR
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            post['curtidas'].contains(widget.login)
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: post['curtidas'].contains(widget.login)
                                                ? Colors.red
                                                : Colors.grey,
                                            size: 20,
                                          ),
                                          onPressed: () => toggleLike(post['id']),
                                        ),
                                        Text(
                                          '${post['curtidas'].length}',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    // COMENTAR
                                    IconButton(
                                      icon: const Icon(Icons.comment, size: 20),
                                      onPressed: () => _showReplyDialog(post['id']),
                                    ),
                                    // EXCLUIR (APENAS SE FOR DO PRÓPRIO USUÁRIO)
                                    if (post['user_login'] == widget.login)
                                      IconButton(
                                        icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                        onPressed: () => deletePost(post['id']),
                                      ),
                                  ],
                                ),
                                // RESPOSTAS
                                _buildReplies(post['id']),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: isPosting
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostScreen(login: widget.login),
                  ),
                ).then((_) => carregarFeed());
              },
        child: const Icon(Icons.add),
      ),
    );
  }
}