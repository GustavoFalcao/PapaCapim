import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const baseUrl = 'https://api.papacapim.just.pro.br';
  static String? token;
  static String? currentUserLogin;
  static int? currentUserId;

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (token != null) 'x-session-token': token!
      };

  // CADASTRAR USUÁRIO
  static Future<Map<String, dynamic>?> cadastrarUsuario(
      String nome, String login, String senha) async {
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

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }

  // LOGIN
  static Future<Map<String, dynamic>?> login(String loginUser, String senha) async {
    final url = Uri.parse('$baseUrl/sessions');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'login': loginUser, 'password': senha}),
    );

    if (response.statusCode == 200) {
      final res = jsonDecode(response.body);
      token = res['token'];
      currentUserLogin = res['user_login'];

      // Pega o id do usuario logado para edicao futura
      final uRes = await getUsuario(currentUserLogin!);
      if (uRes != null) {
        currentUserId = uRes['id'];
        return uRes; // Retorna com o ID
      }
      return res;
    } else {
      return null;
    }
  }

  // PEGAR FEED
  static Future<List<dynamic>> buscarFeed(String login) async {
    final url = Uri.parse('$baseUrl/posts');
    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      List<dynamic> posts = jsonDecode(response.body);
      for (var post in posts) {
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
      return posts;
    } else {
      return [];
    }
  }

  // CRIAR POST
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

  // CURTIR / DESCURTIR
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

  // RESPONDER POST
  static Future<void> replyPost(int postId, String login, String conteudo) async {
    final url = Uri.parse('$baseUrl/posts/$postId/replies');
    await http.post(
      url,
      headers: _headers,
      body: jsonEncode({
        'reply': {'message': conteudo}
      }),
    );
  }

  // EXCLUIR POST
  static Future<void> deletePost(int postId) async {
    final url = Uri.parse('$baseUrl/posts/$postId');
    await http.delete(url, headers: _headers);
  }

  // PEGAR DADOS DE USUÁRIO
  static Future<Map<String, dynamic>?> getUsuario(String login) async {
    final url = Uri.parse('$baseUrl/users/$login');
    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }

  // ATUALIZAR PERFIL
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
}