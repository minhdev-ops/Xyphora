import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:uni_links/uni_links.dart';
import '../event_management/presentation/pages/join_event_page.dart';

class DeepLinkService {
  static const String scheme = 'xyphora';
  static StreamSubscription<String?>? _subscription;

  static Future<void> init() async {
    try {
      final initial = await getInitialLink();
      _handle(initial);
      _subscription = linkStream.listen(_handle);
    } catch (e) {
      debugPrint('DeepLinkService.init error: $e');
    }
  }

  static void _handle(String? link) {
    debugPrint('DeepLinkService: received $link');
    if (link == null) return;

    final uri = Uri.tryParse(link);
    if (uri == null || uri.scheme != scheme) return;

    if (uri.host == 'join') {
      final token = uri.queryParameters['token'];
      if (token != null && token.isNotEmpty) {
        Get.to(() => JoinEventPage(token: token));
      }
    }
  }

  static void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}