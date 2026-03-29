import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://api.papacapim.just.pro.br';
  static String? token;
  static String? currentUserLogin;
  static int? currentUserId;

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (token != null) 'x-session-token': token!
      };

  // ========== AUTENTICAÇÃO ==========
  
  static Future<Map<String, dynamic>?> cadastrarUsuario(
      String nome, String login, String senha) async {
    print("=== CADASTRANDO USUÁRIO ===");
    print("Nome: $nome");
    print("Login: $login");
    print("Senha: $senha");
    
    final url = Uri.parse('$baseUrl/users');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user': {
          'login': login,
          'name': nome,
          'password': senha,
          'password_confirmation': senha
        }
      }),
    );

    print("=== STATUS CADASTRO: ${response.statusCode} ===");
    print("=== RESPOSTA CADASTRO: ${response.body} ===");

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    return null;
  }

  static Future<Map<String, dynamic>?> login(String loginUser, String senha) async {
  print("=== TENTANDO LOGIN COM: $loginUser ===");
  
  final url = Uri.parse('$baseUrl/sessions');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'login': loginUser, 'password': senha}),
  );

  print("=== STATUS LOGIN: ${response.statusCode} ===");
  print("=== RESPOSTA LOGIN: ${response.body} ===");

  if (response.statusCode == 200) {
    final res = jsonDecode(response.body);
    token = res['token'];
    // CONVERTE PARA MINÚSCULO AQUI
    currentUserLogin = res['user_login'].toLowerCase();
    print("=== TOKEN SALVO: $token ===");
    print("=== LOGIN SALVO (minúsculo): $currentUserLogin ===");
    
    final uRes = await getUsuario(currentUserLogin!);
    print("=== DADOS DO USUÁRIO APÓS LOGIN: $uRes ===");
    
    if (uRes != null) {
      currentUserId = uRes['id'];
      print("=== USER ID SALVO: $currentUserId ===");
      return uRes;
    }
    return res;
  }
  return null;
}

  static Future<bool> logout(int sessionId) async {
    final url = Uri.parse('$baseUrl/sessions/$sessionId');
    final response = await http.delete(url, headers: _headers);
    if (response.statusCode == 204) {
      token = null;
      currentUserLogin = null;
      currentUserId = null;
      return true;
    }
    return false;
  }

  // ========== USUÁRIOS ==========
  
  static Future<Map<String, dynamic>?> getUsuario(String login) async {
    print("=== BUSCANDO USUÁRIO: $login ===");
    print("=== TOKEN PRESENTE: ${token != null ? "SIM ($token)" : "NÃO"} ===");
    
    final url = Uri.parse('$baseUrl/users/$login');
    final response = await http.get(
      url, 
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'x-session-token': token!
      }
    );
    
    print("=== STATUS GET USUÁRIO: ${response.statusCode} ===");
    print("=== RESPOSTA GET USUÁRIO: ${response.body} ===");
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  static Future<bool> updateProfile(int userId, String nome, String senha) async {
    final url = Uri.parse('$baseUrl/users/$userId');
    final body = <String, String>{};
    if (nome.isNotEmpty) body['name'] = nome;
    if (senha.isNotEmpty) {
      body['password'] = senha;
      body['password_confirmation'] = senha;
    }
    
    final response = await http.patch(
      url,
      headers: _headers,
      body: jsonEncode({'user': body}),
    );
    return response.statusCode == 201;
  }

  static Future<bool> deleteAccount(int userId) async {
    final url = Uri.parse('$baseUrl/users/$userId');
    final response = await http.delete(url, headers: _headers);
    return response.statusCode == 204;
  }

  static Future<List<dynamic>> searchUsers(String query) async {
    final url = Uri.parse('$baseUrl/users?search=$query');
    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  }

  static Future<List<dynamic>> getAllUsers() async {
    final url = Uri.parse('$baseUrl/users');
    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  }

  // ========== SEGUIDORES ==========
  
  static Future<bool> followUser(String followedLogin) async {
    final url = Uri.parse('$baseUrl/users/$followedLogin/followers');
    final response = await http.post(url, headers: _headers);
    return response.statusCode == 201;
  }

  static Future<bool> unfollowUser(String followedLogin) async {
    final followersUrl = Uri.parse('$baseUrl/users/$followedLogin/followers');
    final followersRes = await http.get(followersUrl, headers: _headers);
    
    if (followersRes.statusCode == 200) {
      List<dynamic> followers = jsonDecode(followersRes.body);
      final follower = followers.firstWhere(
        (f) => f['login'] == currentUserLogin,
        orElse: () => null,
      );
      
      if (follower != null) {
        final deleteUrl = Uri.parse('$baseUrl/users/$followedLogin/followers/${follower['id']}');
        final response = await http.delete(deleteUrl, headers: _headers);
        return response.statusCode == 204;
      }
    }
    return false;
  }

  static Future<bool> isFollowing(String followedLogin) async {
    final url = Uri.parse('$baseUrl/users/$followedLogin/followers');
    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      List<dynamic> followers = jsonDecode(response.body);
      return followers.any((f) => f['login'] == currentUserLogin);
    }
    return false;
  }

  static Future<List<dynamic>> getFollowers(String login) async {
    final url = Uri.parse('$baseUrl/users/$login/followers');
    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  }

  static Future<List<dynamic>> getFollowing(String login) async {
    final url = Uri.parse('$baseUrl/users/$login/following');
    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  }

  // ========== POSTAGENS ==========
  
  static Future<bool> criarPost(String login, String conteudo) async {
    final url = Uri.parse('$baseUrl/posts');
    final response = await http.post(
      url,
      headers: _headers,
      body: jsonEncode({
        'post': {'message': conteudo}
      }),
    );
    return response.statusCode == 201;
  }

  static Future<List<dynamic>> buscarFeed(String login) async {
    final url = Uri.parse('$baseUrl/posts');
    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      List<dynamic> posts = jsonDecode(response.body);
      for (var post in posts) {
        await _carregarCurtidas(post);
        await _carregarRespostas(post);
      }
      return posts;
    }
    return [];
  }

  static Future<List<dynamic>> buscarFeedSeguindo(String login) async {
    final url = Uri.parse('$baseUrl/posts?feed=1');
    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      List<dynamic> posts = jsonDecode(response.body);
      for (var post in posts) {
        await _carregarCurtidas(post);
        await _carregarRespostas(post);
      }
      return posts;
    }
    return [];
  }

  static Future<List<dynamic>> searchPosts(String query) async {
    final url = Uri.parse('$baseUrl/posts?search=$query');
    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      List<dynamic> posts = jsonDecode(response.body);
      for (var post in posts) {
        await _carregarCurtidas(post);
      }
      return posts;
    }
    return [];
  }

  static Future<List<dynamic>> getUserPosts(String login) async {
    final url = Uri.parse('$baseUrl/users/$login/posts');
    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      List<dynamic> posts = jsonDecode(response.body);
      for (var post in posts) {
        await _carregarCurtidas(post);
      }
      return posts;
    }
    return [];
  }

  static Future<bool> deletePost(int postId) async {
    final url = Uri.parse('$baseUrl/posts/$postId');
    final response = await http.delete(url, headers: _headers);
    return response.statusCode == 204;
  }

  // ========== CURTIDAS ==========
  
  static Future<void> toggleLike(int postId, String login) async {
    final likesRes = await http.get(
        Uri.parse('$baseUrl/posts/$postId/likes'),
        headers: _headers);
    if (likesRes.statusCode == 200) {
      List<dynamic> likes = jsonDecode(likesRes.body);
      final hasLiked = likes.any((l) => l['user_login'] == login);
      if (hasLiked) {
        final likeId = likes.firstWhere((l) => l['user_login'] == login)['id'];
        await http.delete(
            Uri.parse('$baseUrl/posts/$postId/likes/$likeId'),
            headers: _headers);
      } else {
        await http.post(Uri.parse('$baseUrl/posts/$postId/likes'),
            headers: _headers);
      }
    }
  }

  static Future<void> _carregarCurtidas(Map<String, dynamic> post) async {
    final likesRes = await http.get(
        Uri.parse('$baseUrl/posts/${post['id']}/likes'),
        headers: _headers);
    if (likesRes.statusCode == 200) {
      List<dynamic> likes = jsonDecode(likesRes.body);
      post['curtidas'] = likes.map((l) => l['user_login']).toList();
    } else {
      post['curtidas'] = [];
    }
  }

  // ========== RESPOSTAS ==========
  
  static Future<bool> replyPost(int postId, String login, String conteudo) async {
    final url = Uri.parse('$baseUrl/posts/$postId/replies');
    final response = await http.post(
      url,
      headers: _headers,
      body: jsonEncode({
        'reply': {'message': conteudo}
      }),
    );
    return response.statusCode == 201;
  }

  static Future<List<dynamic>> getReplies(int postId) async {
    final url = Uri.parse('$baseUrl/posts/$postId/replies');
    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      List<dynamic> replies = jsonDecode(response.body);
      for (var reply in replies) {
        final likesRes = await http.get(
            Uri.parse('$baseUrl/posts/${reply['id']}/likes'),
            headers: _headers);
        if (likesRes.statusCode == 200) {
          List<dynamic> likes = jsonDecode(likesRes.body);
          reply['curtidas'] = likes.map((l) => l['user_login']).toList();
        } else {
          reply['curtidas'] = [];
        }
      }
      return replies;
    }
    return [];
  }

  static Future<void> _carregarRespostas(Map<String, dynamic> post) async {
    final replies = await getReplies(post['id']);
    post['respostas'] = replies;
  }
}