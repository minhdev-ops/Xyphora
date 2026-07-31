import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final String label;
  final String amount;
  final Color amountColor;

  const SummaryCard({
    super.key,
    required this.label,
    required this.amount,
    required this.amountColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF9E9E9E),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            amount,
            style: TextStyle(
              color: amountColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
