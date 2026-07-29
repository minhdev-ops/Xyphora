import 'package:flutter/material.dart';

class SpendingModel {
  final String title;
  final String category;
  final String date;
  final double amount;
  final IconData icon;
  final Color themeColor; // Primary color for the icon/badge text
  final Color bgThemeColor; // Background color for the icon/badge container
  final String paymentMethod;
  final String note;

  const SpendingModel({
    required this.title,
    required this.category,
    required this.date,
    required this.amount,
    required this.icon,
    required this.themeColor,
    required this.bgThemeColor,
    this.paymentMethod = 'Ví MoMo',
    this.note = '',
  });
}
