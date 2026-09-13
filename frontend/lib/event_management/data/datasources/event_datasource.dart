import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:xyphora_frontend/core/exceptions.dart';
import 'package:xyphora_frontend/event_management/domain/models/event_model.dart';
import 'package:xyphora_frontend/event_management/data/services/event_service.dart';

@lazySingleton
class EventDatasource {
  final EventService _service;

  EventDatasource(this._service);

  Future<List<EventModel>> getEvents() async {
    try {
      final response = await _service.fetchEvents();
      final data = response['data'] as List<dynamic>? ?? [];
      return data.map((e) => EventModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (error) {
      _handleError(error);
    }
  }

  Future<EventModel> getEvent(String eventId) async {
    try {
      final response = await _service.getEvent(eventId);
      final data = response['data'];
      if (data == null || data is! Map<String, dynamic>) {
        throw ExceptionWithMessage(mess: 'Không tìm thấy sự kiện');
      }
      return EventModel.fromJson(data);
    } catch (error) {
      _handleError(error);
    }
  }

  Future<Map<String, dynamic>> getInviteLink(String eventId) async {
    try {
      return await _service.getInviteLink(eventId);
    } catch (error) {
      _handleError(error);
    }
  }

  Future<EventModel> createEvent(Map<String, dynamic> data) async {
    try {
      final response = await _service.createEvent(data);
      final eventData = response['data'];
      if (eventData == null || eventData is! Map<String, dynamic>) {
        throw ExceptionWithMessage(mess: 'Tạo sự kiện thất bại');
      }
      return EventModel.fromJson(eventData);
    } catch (error) {
      _handleError(error);
    }
  }

  Future<EventModel> updateEvent(String eventId, Map<String, dynamic> data) async {
    try {
      final response = await _service.updateEvent(eventId, data);
      final eventData = response['data'];
      if (eventData == null || eventData is! Map<String, dynamic>) {
        throw ExceptionWithMessage(mess: 'Cập nhật sự kiện thất bại');
      }
      return EventModel.fromJson(eventData);
    } catch (error) {
      _handleError(error);
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      await _service.deleteEvent(eventId);
    } catch (error) {
      _handleError(error);
    }
  }

  Future<Map<String, dynamic>> joinEvent(String inviteToken) async {
    try {
      return await _service.joinEvent(inviteToken);
    } catch (error) {
      _handleError(error);
    }
  }

  Future<Map<String, dynamic>> claimParticipant(String inviteToken, int participantId) async {
    try {
      return await _service.claimParticipant(inviteToken, participantId);
    } catch (error) {
      _handleError(error);
    }
  }

  Never _handleError(Object error) {
    if (error is ExceptionWithMessage) {
      throw error;
    } else if (error is DioException) {
      final data = error.response?.data;
      String? serverMessage;
      if (data is Map) {
        serverMessage = data['message']?.toString();
      }
      throw ExceptionWithMessage(mess: serverMessage ?? 'Lỗi kết nối máy chủ');
    } else {
      throw ExceptionWithMessage(mess: error.toString());
    }
  }
}