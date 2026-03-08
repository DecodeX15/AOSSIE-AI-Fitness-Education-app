import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static Future<void> saveUserData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();

    for (final entry in data.entries) {
      final key = entry.key;
      final value = entry.value;

      if (value is String) {
        await prefs.setString(key, value);
      } else if (value is List<String>) {
        await prefs.setStringList(key, value);
      }
    }
  }
}
