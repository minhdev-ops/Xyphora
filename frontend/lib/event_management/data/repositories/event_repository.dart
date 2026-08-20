import '../../domain/models/event_model.dart';
import '../datasources/event_datasource.dart';

class EventRepository {
  final EventDatasource _datasource;

  EventRepository(this._datasource);

  Future<List<EventModel>> getEvents({String? token}) {
    return _datasource.getEvents(token: token);
  }

  Future<EventModel> getEvent({
    required String token,
    required String eventId,
  }) {
    return _datasource.getEvent(token: token, eventId: eventId);
  }

  Future<EventModel> updateEvent({
    required String token,
    required String eventId,
    required Map<String, dynamic> data,
  }) {
    return _datasource.updateEvent(
        token: token, eventId: eventId, data: data);
  }

  Future<void> deleteEvent({
    required String token,
    required String eventId,
  }) {
    return _datasource.deleteEvent(token: token, eventId: eventId);
  }
}
