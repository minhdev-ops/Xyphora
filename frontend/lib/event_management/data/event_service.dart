import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/api_config.dart';

class EventService {
  static const String baseUrl = ApiConfig.baseUrl;

  Future<List<Map<String, dynamic>>> fetchEvents(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/events'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final body = jsonDecode(response.body);
      if (response.statusCode == 200 && body['data'] != null) {
        return List<Map<String, dynamic>>.from(body['data']);
      }
      return [];
    } catch (e) {
      debugPrint('EventService.fetchEvents error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createEvent(
      String token, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/events'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }
}
