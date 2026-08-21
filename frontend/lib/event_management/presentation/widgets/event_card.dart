import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/app_theme.dart';
import '../../../config/app_format.dart';
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
        '${AppFormat.date(event.createdAt)} - ${event.participants.length} thành viên';

    return GestureDetector(
      onTap: onTap,
      child: Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: AppRadius.rLg,
        boxShadow: AppShadow.card,
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.successBg,
              borderRadius: AppRadius.rSm,
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
                    style: AppTextStyles.title,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: AppTextStyles.caption),
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
                Text('+${AppFormat.currency(balance)}',
                    style: GoogleFonts.nunito(
                        color: AppColors.success,
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
                Text('bạn được nhận',
                    style: AppTextStyles.small),
              ] else if (balance < 0) ...[
                Text('-${AppFormat.currency(balance)}',
                    style: GoogleFonts.nunito(
                        color: AppColors.error,
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
                Text('bạn nợ',
                    style: AppTextStyles.small),
              ] else ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.inputBg,
                    borderRadius: AppRadius.rXs,
                  ),
                  child: Text('Đã xong',
                      style: AppTextStyles.caption),
                ),
              ],
              const SizedBox(height: 8),
              const Icon(Icons.chevron_right,
                  color: AppColors.textTertiary, size: 20),
            ],
          ),
        ],
      ),
    ),
    );
  }
}
