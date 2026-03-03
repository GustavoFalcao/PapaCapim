import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const baseUrl = 'http://localhost:3000';

  // CADASTRAR USUÁRIO
  static Future<Map<String, dynamic>?> cadastrarUsuario(
      String nome, String email, String senha) async {
    final url = Uri.parse('$baseUrl/users');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nome': nome, 'email': email, 'senha': senha}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body)['user'];
    } else {
      return null;
    }
  }

  // LOGIN
  static Future<Map<String, dynamic>?> login(String email, String senha) async {
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'senha': senha}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['user'];
    } else {
      return null;
    }
  }

  // PEGAR FEED
  static Future<List<dynamic>> buscarFeed(int userId) async {
    final url = Uri.parse('$baseUrl/feed/$userId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return [];
    }
  }

  // CRIAR POST
  static Future<bool> criarPost(int userId, String conteudo) async {
    final url = Uri.parse('$baseUrl/posts');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'conteudo': conteudo}),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  // CURTIR / DESCURTIR
  static Future<void> toggleLike(int postId, int userId) async {
    final url = Uri.parse('$baseUrl/posts/$postId/like');
    await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId}),
    );
  }

  // RESPONDER POST
  static Future<void> replyPost(int postId, int userId, String conteudo) async {
    final url = Uri.parse('$baseUrl/posts/$postId/reply');
    await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'conteudo': conteudo}),
    );
  }

  // EXCLUIR POST
  static Future<void> deletePost(int postId) async {
    final url = Uri.parse('$baseUrl/posts/$postId');
    await http.delete(url);
  }

  // PEGAR DADOS DE USUÁRIO
  static Future<Map<String, dynamic>?> getUsuario(int userId) async {
    final url = Uri.parse('$baseUrl/users/$userId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['user'];
    } else {
      return null;
    }
  }

  // ATUALIZAR PERFIL
  static Future<bool> updateProfile(int userId, String nome, String email) async {
    final url = Uri.parse('$baseUrl/users/$userId');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nome': nome, 'email': email}),
    );
    return response.statusCode == 200;
  }
}