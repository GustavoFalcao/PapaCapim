import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/logo_clickable.dart';
import 'profile_screen.dart';
import 'post_screen.dart';
import 'search_screen.dart';

class FeedScreen extends StatefulWidget {
  final String login;
  const FeedScreen({super.key, required this.login});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List<dynamic> posts = [];
  bool isLoading = true;
  bool showOnlyFollowing = false;

  @override
  void initState() {
    super.initState();
    carregarFeed();
  }

  Future<void> carregarFeed() async {
    setState(() => isLoading = true);
    final dados = showOnlyFollowing 
        ? await ApiService.buscarFeedSeguindo(widget.login)
        : await ApiService.buscarFeed(widget.login);
    
    setState(() {
      posts = dados.where((p) => p['post_id'] == null).toList();
      isLoading = false;
    });
  }

  Future<void> toggleLike(int postId) async {
    await ApiService.toggleLike(postId, widget.login);
    carregarFeed();
  }

  Future<void> deletePost(int postId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Excluir"),
        content: const Text("Excluir esta postagem?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancelar")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Excluir", style: TextStyle(color: Colors.red))),
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
      builder: (_) => AlertDialog(
        title: const Text("Responder"),
        content: TextField(controller: controller, maxLines: 3, decoration: const InputDecoration(hintText: "Digite sua resposta...")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ApiService.replyPost(postId, widget.login, controller.text);
              carregarFeed();
            },
            child: const Text("Enviar"),
          ),
        ],
      ),
    );
  }

  Widget _buildReplies(int postId) {
    return FutureBuilder<List<dynamic>>(
      future: ApiService.getReplies(postId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox.shrink();
        return Container(
          margin: const EdgeInsets.only(top: 10, left: 20),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
          child: Column(
            children: snapshot.data!.map((reply) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.subdirectory_arrow_right, size: 12, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(reply['user_login'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      const Spacer(),
                      if (reply['user_login'] == widget.login)
                        IconButton(icon: const Icon(Icons.delete, size: 14, color: Colors.red), onPressed: () => deletePost(reply['id']), padding: EdgeInsets.zero),
                    ],
                  ),
                  Text(reply['message'] ?? ''),
                ],
              ),
            )).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: LogoClickable(login: widget.login, context: context),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: Icon(showOnlyFollowing ? Icons.people : Icons.people_outline, color: Colors.black),
            onPressed: () => setState(() { showOnlyFollowing = !showOnlyFollowing; carregarFeed(); }),
          ),
          IconButton(icon: const Icon(Icons.search), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SearchScreen(login: widget.login)))),
          IconButton(icon: const Icon(Icons.person), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen(login: widget.login)))),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: carregarFeed,
              child: ListView.builder(
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
                          Row(
                            children: [
                              const Icon(Icons.person, size: 20, color: Colors.green),
                              const SizedBox(width: 8),
                              Text(post['user_login'], style: const TextStyle(fontWeight: FontWeight.bold)),
                              const Spacer(),
                            ],
                          ),
                          Text(post['message'] ?? '', style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(post['curtidas'].contains(widget.login) ? Icons.favorite : Icons.favorite_border, color: post['curtidas'].contains(widget.login) ? Colors.red : Colors.grey),
                                onPressed: () => toggleLike(post['id']),
                              ),
                              Text('${post['curtidas'].length}'),
                              const SizedBox(width: 20),
                              IconButton(icon: const Icon(Icons.comment), onPressed: () => _showReplyDialog(post['id'])),
                              if (post['user_login'] == widget.login)
                                IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => deletePost(post['id'])),
                            ],
                          ),
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
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PostScreen(login: widget.login))).then((_) => carregarFeed()),
        child: const Icon(Icons.add),
      ),
    );
  }
}