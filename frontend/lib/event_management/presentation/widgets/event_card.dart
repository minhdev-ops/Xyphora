import 'package:flutter/material.dart';
import '../../domain/models/event_model.dart';
import 'overlap_avatars.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  final double balance;
  final VoidCallback? onTap;

  const EventCard({super.key, required this.event, required this.balance, this.onTap});

  String _formatVND(double amount) {
    final str = amount.abs().toStringAsFixed(0);
    final buf = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buf.write('.');
      buf.write(str[i]);
    }
    return '${buf.toString()}đ';
  }

  String _formatDate(DateTime dt) {
    const months = [
      'tháng 1', 'tháng 2', 'tháng 3', 'tháng 4',
      'tháng 5', 'tháng 6', 'tháng 7', 'tháng 8',
      'tháng 9', 'tháng 10', 'tháng 11', 'tháng 12',
    ];
    return '${dt.day} ${months[dt.month - 1]}, ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final subtitle =
        '${_formatDate(event.createdAt)} • ${event.participants.length} thành viên';

    return GestureDetector(
      onTap: onTap,
      child: Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(event.emoji, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF9E9E9E))),
                const SizedBox(height: 8),
                OverlapAvatars(participants: event.participants),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (balance > 0) ...[
                Text('+${_formatVND(balance)}',
                    style: const TextStyle(
                        color: Color(0xFF1B9B5A),
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
                const Text('bạn được nhận',
                    style: TextStyle(
                        color: Color(0xFF9E9E9E), fontSize: 11)),
              ] else if (balance < 0) ...[
                Text('-${_formatVND(balance)}',
                    style: const TextStyle(
                        color: Color(0xFFFF3B30),
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
                const Text('bạn nợ',
                    style: TextStyle(
                        color: Color(0xFF9E9E9E), fontSize: 11)),
              ] else ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Đã xong',
                      style: TextStyle(
                          color: Color(0xFF9E9E9E),
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                ),
              ],
              const SizedBox(height: 8),
              const Icon(Icons.chevron_right,
                  color: Color(0xFF9E9E9E), size: 20),
            ],
          ),
        ],
      ),
    ),
    );
  }
}
