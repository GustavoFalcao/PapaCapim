import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'other_profile_screen.dart';

class SearchScreen extends StatefulWidget {
  final String login;
  const SearchScreen({super.key, required this.login});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  List<dynamic> posts = [];
  List<dynamic> users = [];
  bool isLoading = false;
  bool hasSearched = false;
  String currentTab = 'posts'; // 'posts' ou 'users'

  @override
  void initState() {
    super.initState();
    // Carregar usuários sugeridos ao abrir
    carregarSugestoes();
  }

  void carregarSugestoes() async {
    setState(() => isLoading = true);
    final allUsers = await ApiService.getAllUsers();
    // Filtrar o próprio usuário
    final filteredUsers = allUsers.where((u) => u['login'] != widget.login).toList();
    setState(() {
      users = filteredUsers.take(10).toList();
      isLoading = false;
      hasSearched = false;
    });
  }

  void search(String query) async {
    if (query.isEmpty) {
      carregarSugestoes();
      return;
    }
    
    setState(() {
      isLoading = true;
      hasSearched = true;
    });
    
    final postsResult = await ApiService.searchPosts(query);
    final usersResult = await ApiService.searchUsers(query);
    
    setState(() {
      posts = postsResult;
      users = usersResult;
      isLoading = false;
    });
  }

  void clearSearch() {
    searchController.clear();
    carregarSugestoes();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pesquisar"),
        backgroundColor: Colors.green,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: searchController,
              autofocus: false,
              decoration: InputDecoration(
                hintText: "Buscar posts ou usuários...",
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.green),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: clearSearch,
                      )
                    : null,
              ),
              onChanged: (value) {
                if (value.isEmpty) {
                  carregarSugestoes();
                }
              },
              onSubmitted: search,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Abas de navegação
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Row(
              children: [
                _buildTab(
                  icon: Icons.article,
                  label: "Posts",
                  isActive: currentTab == 'posts',
                  onTap: () => setState(() => currentTab = 'posts'),
                ),
                _buildTab(
                  icon: Icons.people,
                  label: "Usuários",
                  isActive: currentTab == 'users',
                  onTap: () => setState(() => currentTab = 'users'),
                ),
              ],
            ),
          ),
          // Conteúdo
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : currentTab == 'posts'
                    ? _buildPostsList()
                    : _buildUsersList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? Colors.green : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isActive ? Colors.green : Colors.grey,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.green : Colors.grey,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostsList() {
    if (posts.isEmpty && hasSearched) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "Nenhum post encontrado",
              style: TextStyle(color: Colors.grey),
            ),
            Text(
              "Tente outra palavra-chave",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      );
    }

    if (posts.isEmpty && !hasSearched) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "Digite algo para buscar",
              style: TextStyle(color: Colors.grey),
            ),
            Text(
              "Busque por palavras em postagens",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () {
              // Ir para o perfil do autor
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
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        post['user_login'] ?? 'Usuário',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
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
                  Text(
                    post['message'] ?? '',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.favorite, size: 14, color: Colors.red),
                      const SizedBox(width: 4),
                      Text(
                        '${post['curtidas']?.length ?? 0} curtidas',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUsersList() {
    if (users.isEmpty && hasSearched) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "Nenhum usuário encontrado",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (users.isEmpty && !hasSearched) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "Usuários sugeridos",
              style: TextStyle(color: Colors.grey),
            ),
            Text(
              "Busque por um nome para encontrar mais",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green,
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
            title: Text(
              user['name'] ?? user['login'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('@${user['login']}'),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {
              if (user['login'] != widget.login) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OtherProfileScreen(
                      login: widget.login,
                      profileLogin: user['login'],
                    ),
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }
}