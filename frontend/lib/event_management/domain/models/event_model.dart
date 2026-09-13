import 'participant_model.dart';
import 'expense_model.dart';

class EventModel {
  final String id;
  final String ownerId;
  final String emoji;
  final String title;
  final String currency;
  final String description;
  final DateTime createdAt;
  final int participantCount;
  final List<ParticipantModel> participants;
  final List<ExpenseModel> expenses;

  EventModel({
    required this.id,
    required this.ownerId,
    required this.emoji,
    required this.title,
    this.currency = 'VND',
    this.description = '',
    required this.createdAt,
    int? participantCount,
    this.participants = const [],
    this.expenses = const [],
  }) : participantCount = participantCount ?? participants.length;

  factory EventModel.fromJson(Map<String, dynamic> json) {
    final eventId = json['event_id'].toString();
    final participants = (json['participants'] as List? ?? [])
        .map((p) => ParticipantModel.fromJson(p as Map<String, dynamic>, eventId))
        .toList();

    return EventModel(
      id: eventId,
      ownerId: json['owner_id'].toString(),
      emoji: json['icon'] as String? ?? '',
      title: json['title'] as String? ?? '',
      currency: json['currency'] as String? ?? 'VND',
      description: json['description'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      participantCount: (json['participants_count'] as num?)?.toInt() ?? participants.length,
      participants: participants,
      expenses: (json['expenses'] as List? ?? [])
          .map((e) => ExpenseModel.fromJson(e as Map<String, dynamic>, eventId, participants))
          .toList(),
    );
  }

  double getUserBalance(String myUserId) {
    double balance = 0;
    for (var expense in expenses) {
      bool iAmPayer = expense.payerId == myUserId;
      for (var split in expense.splits) {
        final participant = participants.firstWhere(
          (p) => p.id == split.participantId,
          orElse: () => ParticipantModel(id: '', eventId: '', userId: ''),
        );
        if (iAmPayer) {
          if (participant.userId != myUserId) balance += split.amount;
        } else {
          if (participant.userId == myUserId) balance -= split.amount;
        }
      }
    }
    return balance;
  }
}