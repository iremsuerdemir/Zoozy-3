import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/comment.dart';
import '../config/api_config.dart';

class CommentServiceHttp {
  static String get baseUrl => ApiConfig.userCommentsUrl;

  final http.Client httpClient;

  CommentServiceHttp({http.Client? httpClient})
      : httpClient = httpClient ?? http.Client();

  /// Get current user ID and name from SharedPreferences (login data)
  Future<Map<String, dynamic>?> _getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    final displayName = prefs.getString('displayName') ?? 'Kullanıcı';
    final photoUrl = prefs.getString('photoUrl');

    if (userId == null) {
      return null;
    }

    return {
      'userId': userId,
      'displayName': displayName,
      'photoUrl': photoUrl,
    };
  }

  /// Get comments for a specific card
  Future<List<Comment>> getCommentsForCard(String cardId) async {
    try {
      final response = await httpClient
          .get(Uri.parse('$baseUrl?cardId=${Uri.encodeComponent(cardId)}'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Comment.fromJson({
              'id': json['id'].toString(),
              'message': json['message'] ?? '',
              'rating': json['rating'] ?? 5,
              'createdAt': json['createdAt'],
              'authorName': json['authorName'] ?? '',
              'authorAvatar': json['authorAvatar'] ?? '',
            })).toList();
      }
      return [];
    } catch (e) {
      print('Yorum yükleme hatası: $e');
      return [];
    }
  }

  /// Add a comment
  Future<bool> addComment(String cardId, Comment comment) async {
    try {
      final user = await _getCurrentUser();
      if (user == null) {
        return false;
      }

      final response = await httpClient
          .post(
            Uri.parse(baseUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'userId': user['userId'],
              'cardId': cardId,
              'message': comment.message,
              'rating': comment.rating,
              'authorName': user['displayName'],
              'authorAvatar': user['photoUrl'],
            }),
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('Yorum ekleme hatası: $e');
      return false;
    }
  }

  /// Delete comments for a card
  Future<bool> deleteCommentsForCard(String cardId) async {
    try {
      final response = await httpClient
          .delete(Uri.parse('$baseUrl/by-card?cardId=${Uri.encodeComponent(cardId)}'))
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      print('Yorum silme hatası: $e');
      return false;
    }
  }

  /// Get comment count for a card
  Future<int> getCommentCountForCard(String cardId) async {
    try {
      final comments = await getCommentsForCard(cardId);
      return comments.length;
    } catch (e) {
      print('Yorum sayısı alma hatası: $e');
      return 0;
    }
  }
}

