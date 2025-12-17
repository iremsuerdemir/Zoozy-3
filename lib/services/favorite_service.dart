import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/favori_item.dart';
import '../config/api_config.dart';

class FavoriteService {
  static String get baseUrl => ApiConfig.userFavoritesUrl;

  final http.Client httpClient;

  FavoriteService({http.Client? httpClient})
      : httpClient = httpClient ?? http.Client();

  /// Get current user ID from SharedPreferences (login data)
  Future<int?> _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  /// Get all favorites for current user, optionally filtered by tip
  Future<List<FavoriteItem>> getUserFavorites({String? tip}) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        return [];
      }

      var url = '$baseUrl?userId=$userId';
      if (tip != null && tip.isNotEmpty) {
        url += '&tip=$tip';
      }

      final response = await httpClient
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => FavoriteItem.fromJson({
              'title': json['title'] ?? '',
              'subtitle': json['subtitle'] ?? '',
              'imageUrl': json['imageUrl'] ?? '',
              'profileImageUrl': json['profileImageUrl'] ?? '',
              'tip': json['tip'] ?? '',
            })).toList();
      }
      return [];
    } catch (e) {
      print('Favori yükleme hatası: $e');
      return [];
    }
  }

  /// Add a favorite
  Future<bool> addFavorite(FavoriteItem favorite) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        return false;
      }

      final response = await httpClient
          .post(
            Uri.parse(baseUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'userId': userId,
              'title': favorite.title,
              'subtitle': favorite.subtitle,
              'imageUrl': favorite.imageUrl,
              'profileImageUrl': favorite.profileImageUrl,
              'tip': favorite.tip,
            }),
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('Favori ekleme hatası: $e');
      return false;
    }
  }

  /// Remove a favorite by identifier
  Future<bool> removeFavorite({
    required String title,
    required String tip,
    String? imageUrl,
  }) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        return false;
      }

      var url = '$baseUrl/by-identifier?userId=$userId&title=${Uri.encodeComponent(title)}&tip=${Uri.encodeComponent(tip)}';
      if (imageUrl != null && imageUrl.isNotEmpty) {
        url += '&imageUrl=${Uri.encodeComponent(imageUrl)}';
      }

      final response = await httpClient
          .delete(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      print('Favori silme hatası: $e');
      return false;
    }
  }

  /// Check if an item is favorite
  Future<bool> isFavorite({
    required String title,
    required String tip,
    String? imageUrl,
  }) async {
    try {
      final favorites = await getUserFavorites(tip: tip);
      return favorites.any((f) {
        if (f.title == title && f.tip == tip) {
          if (imageUrl != null && imageUrl.isNotEmpty) {
            return f.imageUrl == imageUrl;
          }
          return true;
        }
        return false;
      });
    } catch (e) {
      print('Favori kontrol hatası: $e');
      return false;
    }
  }
}

