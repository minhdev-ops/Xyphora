import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../event_management/presentation/pages/join_event_page.dart';

class DeepLinkService {
  static const String scheme = 'xyphora';
  static StreamSubscription<Uri>? _subscription;

  static Future<void> init() async {
    try {
      final appLinks = AppLinks();
      final initial = await appLinks.getInitialLink();
      _handle(initial);
      _subscription = appLinks.uriLinkStream.listen(_handle);
    } catch (e) {
      debugPrint('DeepLinkService.init error: $e');
    }
  }

  static void _handle(Uri? uri) {
    debugPrint('DeepLinkService: received $uri');
    if (uri == null) return;

    if (uri.scheme != scheme) return;

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
