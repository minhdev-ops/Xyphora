import 'package:injectable/injectable.dart';
import 'package:xyphora_frontend/event_management/data/datasources/event_datasource.dart';
import 'package:xyphora_frontend/event_management/domain/models/event_model.dart';

@lazySingleton
class EventRepository {
  final EventDatasource _datasource;

  EventRepository(this._datasource);

  Future<List<EventModel>> getEvents() {
    return _datasource.getEvents();
  }

  Future<EventModel> getEvent(String eventId) {
    return _datasource.getEvent(eventId);
  }

  Future<Map<String, dynamic>> getInviteLink(String eventId) {
    return _datasource.getInviteLink(eventId);
  }

  Future<EventModel> createEvent(Map<String, dynamic> data) {
    return _datasource.createEvent(data);
  }

  Future<EventModel> updateEvent(String eventId, Map<String, dynamic> data) {
    return _datasource.updateEvent(eventId, data);
  }

  Future<void> deleteEvent(String eventId) {
    return _datasource.deleteEvent(eventId);
  }

  Future<Map<String, dynamic>> joinEvent(String inviteToken) {
    return _datasource.joinEvent(inviteToken);
  }

  Future<Map<String, dynamic>> claimParticipant(String inviteToken, int participantId) {
    return _datasource.claimParticipant(inviteToken, participantId);
  }
}