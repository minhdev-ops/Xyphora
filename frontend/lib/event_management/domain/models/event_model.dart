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

  double getUserBalance(String myUserId) {
    double balance = 0;
    for (var expense in expenses) {
      bool iAmPayer = expense.payerId == myUserId;
      for (var split in expense.splits) {
        final participant = participants.firstWhere(
          (p) => p.id == split.participantId,
        );
        if (iAmPayer) {
          if (participant.userId != myUserId) {
            balance += split.amount;
          }
        } else {
          if (participant.userId == myUserId) {
            balance -= split.amount;
          }
        }
      }
    }
    return balance;
  }
}
