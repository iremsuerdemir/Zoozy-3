import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/request_item.dart';
import '../config/api_config.dart';

class RequestService {
  static String get baseUrl => ApiConfig.userRequestsUrl;

  final http.Client httpClient;

  RequestService({http.Client? httpClient})
      : httpClient = httpClient ?? http.Client();

  /// Get current user ID from SharedPreferences (login data)
  Future<int?> _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  /// Get all requests for current user
  Future<List<RequestItem>> getUserRequests() async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        return [];
      }

      final response = await httpClient
          .get(Uri.parse('$baseUrl?userId=$userId'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => RequestItem.fromJson({
              'id': json['id'],
              'petName': json['petName'] ?? '',
              'serviceName': json['serviceName'] ?? '',
              'userPhoto': json['userPhoto'] ?? '',
              'startDate': json['startDate'],
              'endDate': json['endDate'],
              'dayDiff': json['dayDiff'] ?? 0,
              'note': json['note'] ?? '',
              'location': json['location'] ?? '',
            })).toList();
      }
      return [];
    } catch (e) {
      print('Request yükleme hatası: $e');
      return [];
    }
  }

  /// Create a new request
  Future<bool> createRequest(RequestItem request) async {
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
              'petName': request.petName,
              'serviceName': request.serviceName,
              'userPhoto': request.userPhoto,
              'startDate': request.startDate.toIso8601String(),
              'endDate': request.endDate.toIso8601String(),
              'dayDiff': request.dayDiff,
              'note': request.note,
              'location': request.location,
            }),
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('Request oluşturma hatası: $e');
      return false;
    }
  }

  /// Delete a request by ID
  Future<bool> deleteRequest(int requestId) async {
    try {
      final response = await httpClient
          .delete(Uri.parse('$baseUrl/$requestId'))
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      print('Request silme hatası: $e');
      return false;
    }
  }
}

