import '../../../auth/domain/models/user.dart';

class ParticipantModel {
  final String id;
  final String eventId;
  final String userId;
  final UserModel? user;

  ParticipantModel({
    required this.id,
    required this.eventId,
    required this.userId,
    this.user,
  });
}
