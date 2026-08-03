import '../../domain/models/event_model.dart';
import '../datasources/event_datasource.dart';

class EventRepository {
  final EventDatasource _datasource;

  EventRepository(this._datasource);

  Future<List<EventModel>> getEvents({String? token}) {
    return _datasource.getEvents(token: token);
  }
}
