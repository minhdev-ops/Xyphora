import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/api_config.dart';

class EventApiException implements Exception {
  final String message;

  EventApiException(this.message);

  @override
  String toString() => message;
}

class EventService {
  static String get baseUrl => ApiConfig.baseUrl;

  static Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

  static Map<String, dynamic> _decode(http.Response response) {
    final dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      throw EventApiException('Phản hồi từ máy chủ không hợp lệ');
    }
    if (response.statusCode >= 400) {
      final message = decoded is Map<String, dynamic>
          ? (decoded['message'] as String? ?? 'Có lỗi xảy ra')
          : 'Có lỗi xảy ra';
      throw EventApiException(message);
    }
    return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
  }

  Future<List<Map<String, dynamic>>> fetchEvents(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/events'),
        headers: _headers(token),
      );
      final body = _decode(response);
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
      headers: _headers(token),
      body: jsonEncode(data),
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> getInviteLink(String token, String eventId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/events/$eventId/invite'),
      headers: _headers(token),
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> joinEvent(String token, String inviteToken) async {
    final response = await http.post(
      Uri.parse('$baseUrl/events/join'),
      headers: _headers(token),
      body: jsonEncode({'token': inviteToken}),
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> claimParticipant(
      String token, String inviteToken, String participantId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/events/join/claim'),
      headers: _headers(token),
      body: jsonEncode({
        'token': inviteToken,
        'participant_id': int.tryParse(participantId) ?? 0,
      }),
    );
    return _decode(response);
  }
}