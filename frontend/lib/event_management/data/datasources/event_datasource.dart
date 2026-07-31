import 'dart:collection';
import 'package:flutter/foundation.dart';
import '../../../auth/domain/models/user.dart';
import '../../domain/models/participant_model.dart';
import '../../domain/models/expense_split_model.dart';
import '../../domain/models/expense_model.dart';
import '../../domain/models/event_model.dart';
import '../event_service.dart';

class EventDatasource {
  final EventService _service;
  bool _useDummy = true;

  EventDatasource(this._service);

  bool get isUsingDummy => _useDummy;

  void useApi() => _useDummy = false;
  void useDummyData() => _useDummy = true;

  Future<List<EventModel>> getEvents({String? token}) async {
    if (!_useDummy && token != null) {
      try {
        final raw = await _service.fetchEvents(token);
        if (raw.isNotEmpty) {
          return raw.map(_parseEvent).toList();
        }
      } catch (e) {
        debugPrint('EventDatasource: API failed, fallback to dummy: $e');
      }
    }
    return _buildDummyData();
  }

  EventModel _parseEvent(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      emoji: json['emoji'] as String? ?? '',
      title: json['title'] as String,
      currency: json['currency'] as String? ?? 'VND',
      description: json['description'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      participants: (json['participants'] as List? ?? [])
          .map((p) => ParticipantModel(
                id: p['id'] as String,
                eventId: p['event_id'] as String,
                userId: p['user_id'] as String,
                user: p['user'] != null
                    ? UserModel(
                        id: p['user']['id'] as String,
                        name: p['user']['name'] as String,
                        email: p['user']['email'] as String,
                      )
                    : null,
              ))
          .toList(),
      expenses: (json['expenses'] as List? ?? [])
          .map((e) => ExpenseModel(
                id: e['id'] as String,
                eventId: e['event_id'] as String,
                title: e['title'] as String,
                amount: (e['amount'] as num).toDouble(),
                dayPaid: DateTime.parse(e['day_paid'] as String),
                payerId: e['payer_id'] as String,
                splits: (e['splits'] as List? ?? [])
                    .map((s) => ExpenseSplitModel(
                          expenseId: s['expense_id'] as String,
                          participantId: s['participant_id'] as String,
                          amount: (s['amount'] as num).toDouble(),
                          status: s['status'] as String? ?? 'pending',
                        ))
                    .toList(),
              ))
          .toList(),
    );
  }

  List<EventModel> _buildDummyData() {
    final u1 = UserModel(id: 'user_1', name: 'Bạn', email: 'ban@email.com');
    final u2 = UserModel(id: 'user_2', name: 'Minh', email: 'minh@email.com');
    final u3 = UserModel(id: 'user_3', name: 'Lan', email: 'lan@email.com');
    final u4 = UserModel(id: 'user_4', name: 'Hùng', email: 'hung@email.com');
    final u5 = UserModel(id: 'user_5', name: 'Bảo', email: 'bao@email.com');
    final u6 = UserModel(id: 'user_6', name: 'Trang', email: 'trang@email.com');
    final u7 = UserModel(id: 'user_7', name: 'Kiên', email: 'kien@email.com');
    final u8 = UserModel(id: 'user_8', name: 'Nam', email: 'nam@email.com');
    final u9 = UserModel(id: 'user_9', name: 'An', email: 'an@email.com');
    final u10 = UserModel(id: 'user_10', name: 'Phương', email: 'phuong@email.com');

    final users = UnmodifiableMapView({
      'user_1': u1, 'user_2': u2, 'user_3': u3, 'user_4': u4, 'user_5': u5,
      'user_6': u6, 'user_7': u7, 'user_8': u8, 'user_9': u9, 'user_10': u10,
    });

    return [
      EventModel(id: 'ev1', ownerId: 'user_5', emoji: '⛰️',
          title: 'Du lịch Đà Lạt',
          createdAt: DateTime(2026, 7, 20),
          description: 'Chuyến đi cuối tuần',
          participants: [
            ParticipantModel(id: 'ev1_p1', eventId: 'ev1', userId: 'user_1', user: users['user_1']),
            ParticipantModel(id: 'ev1_p2', eventId: 'ev1', userId: 'user_5', user: users['user_5']),
            ParticipantModel(id: 'ev1_p3', eventId: 'ev1', userId: 'user_2', user: users['user_2']),
            ParticipantModel(id: 'ev1_p4', eventId: 'ev1', userId: 'user_3', user: users['user_3']),
            ParticipantModel(id: 'ev1_p5', eventId: 'ev1', userId: 'user_4', user: users['user_4']),
          ],
          expenses: [
            ExpenseModel(id: 'ev1_exp1', eventId: 'ev1', title: 'Khách sạn',
                amount: 625000, dayPaid: DateTime(2026, 7, 19), payerId: 'user_5',
                splits: [
                  ExpenseSplitModel(expenseId: 'ev1_exp1', participantId: 'ev1_p1', amount: 125000),
                  ExpenseSplitModel(expenseId: 'ev1_exp1', participantId: 'ev1_p2', amount: 125000),
                  ExpenseSplitModel(expenseId: 'ev1_exp1', participantId: 'ev1_p3', amount: 125000),
                  ExpenseSplitModel(expenseId: 'ev1_exp1', participantId: 'ev1_p4', amount: 125000),
                  ExpenseSplitModel(expenseId: 'ev1_exp1', participantId: 'ev1_p5', amount: 125000),
                ]),
          ]),
      EventModel(id: 'ev2', ownerId: 'user_1', emoji: '🎂',
          title: 'Tiệc sinh nhật Minh',
          createdAt: DateTime(2026, 7, 15),
          description: 'Sinh nhật bất ngờ',
          participants: [
            ParticipantModel(id: 'ev2_p1', eventId: 'ev2', userId: 'user_1', user: users['user_1']),
            ParticipantModel(id: 'ev2_p2', eventId: 'ev2', userId: 'user_2', user: users['user_2']),
            ParticipantModel(id: 'ev2_p3', eventId: 'ev2', userId: 'user_3', user: users['user_3']),
            ParticipantModel(id: 'ev2_p4', eventId: 'ev2', userId: 'user_4', user: users['user_4']),
          ],
          expenses: [
            ExpenseModel(id: 'ev2_exp1', eventId: 'ev2', title: 'Bánh kem',
                amount: 400000, dayPaid: DateTime(2026, 7, 14), payerId: 'user_1',
                splits: [
                  ExpenseSplitModel(expenseId: 'ev2_exp1', participantId: 'ev2_p1', amount: 100000),
                  ExpenseSplitModel(expenseId: 'ev2_exp1', participantId: 'ev2_p2', amount: 100000),
                  ExpenseSplitModel(expenseId: 'ev2_exp1', participantId: 'ev2_p3', amount: 100000),
                  ExpenseSplitModel(expenseId: 'ev2_exp1', participantId: 'ev2_p4', amount: 100000),
                ]),
            ExpenseModel(id: 'ev2_exp2', eventId: 'ev2', title: 'Trang trí',
                amount: 240000, dayPaid: DateTime(2026, 7, 14), payerId: 'user_1',
                splits: [
                  ExpenseSplitModel(expenseId: 'ev2_exp2', participantId: 'ev2_p1', amount: 60000),
                  ExpenseSplitModel(expenseId: 'ev2_exp2', participantId: 'ev2_p2', amount: 60000),
                  ExpenseSplitModel(expenseId: 'ev2_exp2', participantId: 'ev2_p3', amount: 60000),
                  ExpenseSplitModel(expenseId: 'ev2_exp2', participantId: 'ev2_p4', amount: 60000),
                ]),
            ExpenseModel(id: 'ev2_exp3', eventId: 'ev2', title: 'Đồ ăn',
                amount: 560000, dayPaid: DateTime(2026, 7, 15), payerId: 'user_3',
                splits: [
                  ExpenseSplitModel(expenseId: 'ev2_exp3', participantId: 'ev2_p1', amount: 140000),
                  ExpenseSplitModel(expenseId: 'ev2_exp3', participantId: 'ev2_p2', amount: 140000),
                  ExpenseSplitModel(expenseId: 'ev2_exp3', participantId: 'ev2_p3', amount: 140000),
                  ExpenseSplitModel(expenseId: 'ev2_exp3', participantId: 'ev2_p4', amount: 140000),
                ]),
          ]),
      EventModel(id: 'ev3', ownerId: 'user_1', emoji: '🏠',
          title: 'Nhà Airbnb Hội An',
          createdAt: DateTime(2026, 6, 10),
          description: 'Kỳ nghỉ hè',
          participants: [
            ParticipantModel(id: 'ev3_p1', eventId: 'ev3', userId: 'user_1', user: users['user_1']),
            ParticipantModel(id: 'ev3_p2', eventId: 'ev3', userId: 'user_5', user: users['user_5']),
            ParticipantModel(id: 'ev3_p3', eventId: 'ev3', userId: 'user_3', user: users['user_3']),
          ],
          expenses: [
            ExpenseModel(id: 'ev3_exp1', eventId: 'ev3', title: 'Tiền thuê nhà',
                amount: 900000, dayPaid: DateTime(2026, 6, 9), payerId: 'user_1',
                splits: [
                  ExpenseSplitModel(expenseId: 'ev3_exp1', participantId: 'ev3_p1', amount: 300000),
                  ExpenseSplitModel(expenseId: 'ev3_exp1', participantId: 'ev3_p2', amount: 300000),
                  ExpenseSplitModel(expenseId: 'ev3_exp1', participantId: 'ev3_p3', amount: 300000),
                ]),
            ExpenseModel(id: 'ev3_exp2', eventId: 'ev3', title: 'Phí dọn dẹp',
                amount: 600000, dayPaid: DateTime(2026, 6, 12), payerId: 'user_5',
                splits: [
                  ExpenseSplitModel(expenseId: 'ev3_exp2', participantId: 'ev3_p1', amount: 200000),
                  ExpenseSplitModel(expenseId: 'ev3_exp2', participantId: 'ev3_p2', amount: 200000),
                  ExpenseSplitModel(expenseId: 'ev3_exp2', participantId: 'ev3_p3', amount: 200000),
                ]),
            ExpenseModel(id: 'ev3_exp3', eventId: 'ev3', title: 'Tiền ăn',
                amount: 1200000, dayPaid: DateTime(2026, 6, 11), payerId: 'user_3',
                splits: [
                  ExpenseSplitModel(expenseId: 'ev3_exp3', participantId: 'ev3_p1', amount: 400000),
                  ExpenseSplitModel(expenseId: 'ev3_exp3', participantId: 'ev3_p2', amount: 400000),
                  ExpenseSplitModel(expenseId: 'ev3_exp3', participantId: 'ev3_p3', amount: 400000),
                ]),
          ]),
      EventModel(id: 'ev4', ownerId: 'user_1', emoji: '🏖️',
          title: 'Đi biển Vũng Tàu',
          createdAt: DateTime(2026, 7, 25),
          description: 'Tắm biển cuối tuần',
          participants: [
            ParticipantModel(id: 'ev4_p1', eventId: 'ev4', userId: 'user_1', user: users['user_1']),
            ParticipantModel(id: 'ev4_p2', eventId: 'ev4', userId: 'user_6', user: users['user_6']),
            ParticipantModel(id: 'ev4_p3', eventId: 'ev4', userId: 'user_7', user: users['user_7']),
            ParticipantModel(id: 'ev4_p4', eventId: 'ev4', userId: 'user_8', user: users['user_8']),
          ],
          expenses: [
            ExpenseModel(id: 'ev4_exp1', eventId: 'ev4', title: 'Thuê xe',
                amount: 480000, dayPaid: DateTime(2026, 7, 25), payerId: 'user_1',
                splits: [
                  ExpenseSplitModel(expenseId: 'ev4_exp1', participantId: 'ev4_p1', amount: 120000),
                  ExpenseSplitModel(expenseId: 'ev4_exp1', participantId: 'ev4_p2', amount: 120000),
                  ExpenseSplitModel(expenseId: 'ev4_exp1', participantId: 'ev4_p3', amount: 120000),
                  ExpenseSplitModel(expenseId: 'ev4_exp1', participantId: 'ev4_p4', amount: 120000),
                ]),
            ExpenseModel(id: 'ev4_exp2', eventId: 'ev4', title: 'Đồ ăn',
                amount: 600000, dayPaid: DateTime(2026, 7, 25), payerId: 'user_6',
                splits: [
                  ExpenseSplitModel(expenseId: 'ev4_exp2', participantId: 'ev4_p1', amount: 150000),
                  ExpenseSplitModel(expenseId: 'ev4_exp2', participantId: 'ev4_p2', amount: 150000),
                  ExpenseSplitModel(expenseId: 'ev4_exp2', participantId: 'ev4_p3', amount: 150000),
                  ExpenseSplitModel(expenseId: 'ev4_exp2', participantId: 'ev4_p4', amount: 150000),
                ]),
          ]),
      EventModel(id: 'ev5', ownerId: 'user_9', emoji: '🍽️',
          title: 'Ăn tối cuối tuần',
          createdAt: DateTime(2026, 7, 28),
          description: 'Tụ họp bạn bè',
          participants: [
            ParticipantModel(id: 'ev5_p1', eventId: 'ev5', userId: 'user_1', user: users['user_1']),
            ParticipantModel(id: 'ev5_p2', eventId: 'ev5', userId: 'user_9', user: users['user_9']),
            ParticipantModel(id: 'ev5_p3', eventId: 'ev5', userId: 'user_10', user: users['user_10']),
          ],
          expenses: [
            ExpenseModel(id: 'ev5_exp1', eventId: 'ev5', title: 'Suất ăn',
                amount: 234000, dayPaid: DateTime(2026, 7, 28), payerId: 'user_9',
                splits: [
                  ExpenseSplitModel(expenseId: 'ev5_exp1', participantId: 'ev5_p1', amount: 78000),
                  ExpenseSplitModel(expenseId: 'ev5_exp1', participantId: 'ev5_p2', amount: 78000),
                  ExpenseSplitModel(expenseId: 'ev5_exp1', participantId: 'ev5_p3', amount: 78000),
                ]),
          ]),
    ];
  }
}
