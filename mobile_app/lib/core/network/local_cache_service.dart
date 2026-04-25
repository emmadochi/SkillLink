import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalCacheService {
  static const String _prefix = 'sl_cache_';
  
  // Cache durations
  static const Duration defaultExpiry = Duration(hours: 24);

  static Future<void> set(String key, dynamic data, {Duration? expiry}) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheData = {
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'expiry': (expiry ?? defaultExpiry).inMilliseconds,
      'data': data,
    };
    await prefs.setString(_prefix + key, jsonEncode(cacheData));
  }

  static Future<dynamic> get(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final String? cachedStr = prefs.getString(_prefix + key);
    
    if (cachedStr == null) return null;

    try {
      final Map<String, dynamic> cacheData = jsonDecode(cachedStr);
      final int timestamp = cacheData['timestamp'];
      final int expiryMs = cacheData['expiry'];
      
      // We still return stale data if needed, but we can check expiry
      // For "light" network, we return even if stale if network fails
      return cacheData['data'];
    } catch (e) {
      return null;
    }
  }

  static Future<bool> isExpired(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final String? cachedStr = prefs.getString(_prefix + key);
    if (cachedStr == null) return true;

    try {
      final Map<String, dynamic> cacheData = jsonDecode(cachedStr);
      final int timestamp = cacheData['timestamp'];
      final int expiryMs = cacheData['expiry'];
      final DateTime expiryDate = DateTime.fromMillisecondsSinceEpoch(timestamp + expiryMs);
      
      return DateTime.now().isAfter(expiryDate);
    } catch (e) {
      return true;
    }
  }

  static Future<void> clear(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefix + key);
  }
}
