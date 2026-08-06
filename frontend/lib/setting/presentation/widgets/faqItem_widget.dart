import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../domain/models/faqItem_model.dart';

class FaqItemWidget extends StatefulWidget {
  final FAQItem faq;

  const FaqItemWidget({super.key, required this.faq});

  @override
  State<FaqItemWidget> createState() => _FaqItemWidgetState();
}

class _FaqItemWidgetState extends State<FaqItemWidget> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
          title: Text(
            widget.faq.question,
            style: const TextStyle(
              color: Color(0xFF0C3D2B),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          trailing: Icon(
            isExpanded ? Icons.keyboard_arrow_down_rounded : Icons.chevron_right_rounded,
            color: Colors.grey,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          dense: true,
        ),
        if (isExpanded)
          Container(
            width: double.infinity,
            color: const Color(0xFFEDF3EE), // Nền xanh xám nhạt cho phần câu trả lời
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              widget.faq.answer,
              style: const TextStyle(
                color: Color(0xFF6B7E71),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
      ],
    );
  }
}