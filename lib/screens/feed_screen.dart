import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'profile_screen.dart';
import 'edit_profile_screen.dart';
import 'post_screen.dart';

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

  @override
  void initState() {
    super.initState();
    carregarFeed();
  }

  Future<void> carregarFeed() async {
    setState(() => isLoading = true);
    final dados = await ApiService.buscarFeed(widget.login);
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
    await ApiService.deletePost(postId);
    carregarFeed();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Feed"),
        actions: [
          // Botão para acessar o perfil
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
          ),
          // Botão para editar perfil
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
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: carregarFeed,
              child: ListView.builder(
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
                          Text(post['message'] ?? '', style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              IconButton(
                                icon: Icon(
                                  post['curtidas'].contains(widget.login)
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: post['curtidas'].contains(widget.login)
                                      ? Colors.red
                                      : Colors.grey,
                                ),
                                onPressed: () => toggleLike(post['id']),
                              ),
                              IconButton(
                                icon: const Icon(Icons.comment),
                                onPressed: () {
                                  TextEditingController controller = TextEditingController();
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text("Responder"),
                                      content: TextField(
                                        controller: controller,
                                        decoration: const InputDecoration(
                                          hintText: "Digite sua resposta...",
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
                                            replyPost(post['id'], controller.text);
                                          },
                                          child: const Text("Enviar"),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => deletePost(post['id']),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: isPosting
            ? null
            : () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostScreen(login: widget.login),
                  ),
                );
              },
        child: const Icon(Icons.add),
      ),
    );
  }
}