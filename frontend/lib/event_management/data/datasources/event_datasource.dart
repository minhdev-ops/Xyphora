import 'package:flutter/foundation.dart';
import '../../../auth/domain/models/user.dart';
import '../../../config/token_storage.dart';
import '../../domain/models/participant_model.dart';
import '../../domain/models/expense_split_model.dart';
import '../../domain/models/expense_model.dart';
import '../../domain/models/event_model.dart';
import '../event_service.dart';

class EventDatasource {
  final EventService _service;

  EventDatasource(this._service);

  Future<List<EventModel>> getEvents({String? token}) async {
    final authToken = token ?? await TokenStorage.read();
    if (authToken != null && authToken.isNotEmpty) {
      try {
        final raw = await _service.fetchEvents(authToken);
        return raw.map(_parseEvent).toList();
      } catch (e) {
        debugPrint('EventDatasource API error: $e');
        return [];
      }
    }
    return [];
  }

  EventModel _parseEvent(Map<String, dynamic> json) {
    final id = json['event_id']?.toString() ?? json['id']?.toString() ?? '';
    final ownerId = json['owner_id']?.toString() ?? '';
    return EventModel(
      id: id,
      ownerId: ownerId,
      emoji: json['icon'] as String? ?? json['emoji'] as String? ?? '🎉',
      title: json['title'] as String? ?? '',
      currency: json['currency'] as String? ?? 'VND',
      description: json['description'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      participants: (json['participants'] as List? ?? [])
          .map((p) => ParticipantModel(
                id: p['participant_id']?.toString() ?? p['id']?.toString() ?? '',
                eventId: id,
                userId: p['user_id']?.toString() ?? '',
                user: p['user'] != null
                    ? UserModel(
                        id: p['user']['id']?.toString() ?? '',
                        name: p['user']['name'] as String? ?? '',
                        email: p['user']['email'] as String? ?? '',
                      )
                    : null,
              ))
          .toList(),
      expenses: (json['expenses'] as List? ?? [])
          .map((e) => ExpenseModel(
                id: e['expense_id']?.toString() ?? e['id']?.toString() ?? '',
                eventId: id,
                title: e['title'] as String? ?? '',
                amount: (e['amount'] as num?)?.toDouble() ?? 0.0,
                dayPaid: e['expense_date'] != null
                    ? DateTime.tryParse(e['expense_date'] as String) ?? DateTime.now()
                    : DateTime.now(),
                payerId: e['payer_id']?.toString() ?? '',
                splits: (e['splits'] as List? ?? [])
                    .map((s) => ExpenseSplitModel(
                          expenseId: s['expense_id']?.toString() ?? '',
                          participantId: s['participant_id']?.toString() ?? '',
                          amount: (s['amount'] as num?)?.toDouble() ?? 0.0,
                          status: s['status'] as String? ?? 'pending',
                        ))
                    .toList(),
              ))
          .toList(),
    );
  }
}
