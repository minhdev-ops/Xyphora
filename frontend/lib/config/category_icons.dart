import 'package:flutter/material.dart';

const Map<String, IconData> categoryIconMap = {
  'restaurant': Icons.restaurant,
  'car': Icons.directions_car,
  'bed': Icons.hotel,
  'fuel': Icons.local_gas_station,
  'ticket': Icons.confirmation_number,
  'receipt': Icons.receipt_long,
  'shopping': Icons.shopping_bag,
  'health': Icons.medical_services,
  'education': Icons.school,
  'gift': Icons.card_giftcard,
};

IconData categoryIconFor(String? icon) => categoryIconMap[icon] ?? Icons.category;

Color categoryColorFor(
  String? hex, {
  Color fallback = const Color(0xFF0C3D2B),
}) {
  if (hex == null || hex.isEmpty) return fallback;
  var value = hex.replaceFirst('#', '');
  if (value.length == 6) value = 'FF$value';
  final parsed = int.tryParse(value, radix: 16);
  return parsed == null ? fallback : Color(parsed);
}