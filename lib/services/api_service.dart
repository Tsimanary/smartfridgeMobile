import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.1.100:5000'; // ⚠️ CHANGEZ
  final storage = const FlutterSecureStorage();

  // Connexion - retourne directement le JSON
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        await storage.write(key: 'token', value: data['data']['token']);
        return {
          'success': true,
          'user': data['data']['user'], // JSON brut, pas d'objet User
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Erreur de connexion',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion au serveur: $e',
      };
    }
  }

  // Recherche - retourne directement le JSON
  Future<Map<String, dynamic>> searchProducts(String query) async {
    try {
      final token = await storage.read(key: 'token');

      if (token == null) {
        return {'success': false, 'message': 'Non authentifié'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/search'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'query': query}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        return {
          'success': true,
          'count': data['data']['count'],
          'total_quantity': data['data']['total_quantity'],
          'products': data['data']['products'], // Liste JSON brute
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Erreur de recherche',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur: $e',
      };
    }
  }

  // Tous les produits - JSON brut
  Future<Map<String, dynamic>> getAllProducts() async {
    try {
      final token = await storage.read(key: 'token');

      if (token == null) {
        return {'success': false, 'message': 'Non authentifié'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/produits'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        return {
          'success': true,
          'count': data['data']['count'],
          'products': data['data']['products'], // Liste JSON brute
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Erreur',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur: $e',
      };
    }
  }

  Future<void> logout() async {
    await storage.delete(key: 'token');
  }

  Future<bool> isLoggedIn() async {
    final token = await storage.read(key: 'token');
    return token != null;
  }
}