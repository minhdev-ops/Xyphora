import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lưu token đăng nhập.
///
/// - Web: dùng SharedPreferences (nền localStorage) vì flutter_secure_storage
///   bản web mất dữ liệu khi reload trang trong môi trường hiện tại.
/// - Mobile: dùng FlutterSecureStorage (Keychain/Keystore) giữ nguyên hành vi cũ.
class TokenStorage {
  TokenStorage._();

  static const String _key = 'auth_token';

  static Future<String?> read() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_key);
    }
    const storage = FlutterSecureStorage();
    return storage.read(key: _key);
  }

  static Future<void> write(String token) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, token);
      return;
    }
    const storage = FlutterSecureStorage();
    await storage.write(key: _key, value: token);
  }

  static Future<void> delete() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
      return;
    }
    const storage = FlutterSecureStorage();
    await storage.delete(key: _key);
  }
}