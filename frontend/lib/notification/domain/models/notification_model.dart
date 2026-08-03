import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String time;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final RxBool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    bool isRead = false,
  }) : isRead = isRead.obs;
}
