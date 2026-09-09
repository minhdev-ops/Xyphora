import 'package:xyphora_frontend/auth/domain/models/user.dart';

class ParticipantModel {
  final String id;
  final String eventId;
  final String userId;
  final String displayName;
  final UserModel? user;

  ParticipantModel({
    required this.id,
    required this.eventId,
    required this.userId,
    this.displayName = '',
    this.user,
  });

  factory ParticipantModel.fromJson(Map<String, dynamic> json, [String? eventId]) {
    final userRaw = json['user'];
    return ParticipantModel(
      id: json['participant_id'].toString(),
      eventId: eventId ?? json['event_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      displayName: json['display_name'] as String? ?? '',
      user: userRaw != null
          ? UserModel(
              id: (userRaw as Map<String, dynamic>)['id'].toString(),
              name: userRaw['name'] as String? ?? '',
              email: userRaw['email'] as String? ?? '',
              avatarUrl: userRaw['avatar'] as String?,
            )
          : null,
    );
  }

  String get name => user?.name ?? displayName;
}