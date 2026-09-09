import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:xyphora_frontend/config/backend_config.dart';
import 'package:xyphora_frontend/config/token_storage.dart';

@lazySingleton
class EventService {
  final Dio _dio;
  final String baseUrl;

  EventService()
      : _dio = Dio(),
        baseUrl = BackendConfig.baseUrl {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await TokenStorage.read();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        return handler.next(error);
      },
    ));
  }

  Options get _options => Options(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

  Future<Map<String, dynamic>> fetchEvents() async {
    final response = await _dio.get(
      '$baseUrl/events',
      options: _options,
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createEvent(Map<String, dynamic> data) async {
    final response = await _dio.post(
      '$baseUrl/events',
      data: data,
      options: _options,
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getEvent(String eventId) async {
    final response = await _dio.get(
      '$baseUrl/events/$eventId',
      options: _options,
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateEvent(String eventId, Map<String, dynamic> data) async {
    final response = await _dio.put(
      '$baseUrl/events/$eventId',
      data: data,
      options: _options,
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> deleteEvent(String eventId) async {
    final response = await _dio.delete(
      '$baseUrl/events/$eventId',
      options: _options,
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getInviteLink(String eventId) async {
    final response = await _dio.get(
      '$baseUrl/events/$eventId/invite',
      options: _options,
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> joinEvent(String inviteToken) async {
    final response = await _dio.post(
      '$baseUrl/events/join',
      data: {'token': inviteToken},
      options: _options,
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> claimParticipant(String inviteToken, int participantId) async {
    final response = await _dio.post(
      '$baseUrl/events/join/claim',
      data: {
        'token': inviteToken,
        'participant_id': participantId,
      },
      options: _options,
    );
    return response.data as Map<String, dynamic>;
  }
}