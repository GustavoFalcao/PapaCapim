import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/logo_clickable.dart';
import 'other_profile_screen.dart';

class SearchScreen extends StatefulWidget {
  final String login;
  const SearchScreen({super.key, required this.login});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController search = TextEditingController();
  List<dynamic> users = [];
  List<dynamic> posts = [];
  bool isLoading = false;
  int tab = 0;

  void buscar() async {
    if (search.text.isEmpty) return;
    setState(() => isLoading = true);
    users = await ApiService.searchUsers(search.text);
    posts = await ApiService.searchPosts(search.text);
    if (!mounted) return;
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: LogoClickable(login: widget.login, context: context),
        backgroundColor: Colors.green,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: search,
              decoration: InputDecoration(
                hintText: "Buscar...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                suffixIcon: IconButton(icon: const Icon(Icons.search), onPressed: buscar),
              ),
              onSubmitted: (_) => buscar(),
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Row(
                  children: [
                    _tab("Usuários", 0), _tab("Posts", 1),
                  ],
                ),
                Expanded(
                  child: tab == 0
                      ? ListView.builder(
                          itemCount: users.length,
                          itemBuilder: (_, i) => ListTile(
                            leading: const CircleAvatar(child: Icon(Icons.person)),
                            title: Text(users[i]['name'] ?? users[i]['login']),
                            subtitle: Text('@${users[i]['login']}'),
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OtherProfileScreen(login: widget.login, profileLogin: users[i]['login']))),
                          ),
                        )
                      : ListView.builder(
                          itemCount: posts.length,
                          itemBuilder: (_, i) => Card(
                            margin: const EdgeInsets.all(8),
                            child: ListTile(
                              title: Text(posts[i]['message'] ?? ''),
                              subtitle: Text('@${posts[i]['user_login']}'),
                            ),
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _tab(String label, int index) {
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => tab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: tab == index ? Colors.green : Colors.transparent, width: 2)),
          ),
          child: Text(label, textAlign: TextAlign.center, style: TextStyle(color: tab == index ? Colors.green : Colors.grey)),
        ),
      ),
    );
  }
}