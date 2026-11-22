import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageRepository {
  final SharedPreferencesAsync _preferences = SharedPreferencesAsync();

  Future<void> setToken(String token) async {
    await _preferences.setString('x-auth-token', token);
  }

  Future<String?> getToken() async {
    try {
      return await _preferences.getString('x-auth-token');
    } catch (e) {
      debugPrint('Error reading auth token: $e');
      return null;
    }
  }
}
