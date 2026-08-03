import 'package:flutter/material.dart';
import '../../domain/models/participant_model.dart';

class OverlapAvatars extends StatelessWidget {
  final List<ParticipantModel> participants;
  final int maxVisible;

  const OverlapAvatars({
    super.key,
    required this.participants,
    this.maxVisible = 4,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> avatars = [];
    final visible = participants.length > maxVisible ? maxVisible - 1 : participants.length;

    for (int i = 0; i < visible; i++) {
      final p = participants[i];
      final initial = (p.user?.name.isNotEmpty == true)
          ? p.user!.name[0].toUpperCase()
          : '?';
      avatars.add(Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: Color(0xFF0A4226),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(initial,
            style: const TextStyle(
                color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
      ));
    }

    if (participants.length > maxVisible) {
      avatars.add(Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: const Color(0xFF1B9B5A).withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text('+${participants.length - visible}',
            style: const TextStyle(
                color: Color(0xFF1B9B5A), fontSize: 9, fontWeight: FontWeight.bold)),
      ));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(avatars.length,
          (i) => Transform.translate(offset: Offset(-(i * 10).toDouble(), 0), child: avatars[i])),
    );
  }
}
