import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/logo_clickable.dart';

class OtherProfileScreen extends StatefulWidget {
  final String login;
  final String profileLogin;
  const OtherProfileScreen({super.key, required this.login, required this.profileLogin});

  @override
  State<OtherProfileScreen> createState() => _OtherProfileScreenState();
}

class _OtherProfileScreenState extends State<OtherProfileScreen> {
  Map<String, dynamic>? user;
  List<dynamic> posts = [];
  bool isLoading = true;
  bool isFollowing = false;

  @override
  void initState() {
    super.initState();
    carregar();
  }

  Future<void> carregar() async {
    setState(() => isLoading = true);
    user = await ApiService.getUsuario(widget.profileLogin);
    posts = await ApiService.getUserPosts(widget.profileLogin);
    isFollowing = await ApiService.isFollowing(widget.profileLogin);
    if (!mounted) return;
    setState(() => isLoading = false);
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
      ),
      body: RefreshIndicator(
        onRefresh: carregar,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              const CircleAvatar(radius: 50, backgroundColor: Colors.green, child: Icon(Icons.person, size: 50, color: Colors.white)),
              const SizedBox(height: 10),
              Text(user?['name'] ?? '', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text('@${user?['login'] ?? ''}', style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  setState(() => isFollowing = !isFollowing);
                  isFollowing ? await ApiService.followUser(widget.profileLogin) : await ApiService.unfollowUser(widget.profileLogin);
                },
                style: ElevatedButton.styleFrom(backgroundColor: isFollowing ? Colors.grey : Colors.green),
                child: Text(isFollowing ? "Deixar de Seguir" : "Seguir", style: const TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 20),
              const Text("Postagens", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: posts.length,
                itemBuilder: (_, i) => Card(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: ListTile(
                    leading: const Icon(Icons.message, color: Colors.green),
                    title: Text(posts[i]['message'] ?? '', maxLines: 2),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.favorite, size: 16, color: Colors.red),
                        Text(' ${posts[i]['curtidas']?.length ?? 0}'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}