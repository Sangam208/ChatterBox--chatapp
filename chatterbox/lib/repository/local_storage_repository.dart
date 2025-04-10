import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageRepository {
  void setToken(String token) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    try {
      preferences.setString('x-auth-token', token);
    } catch (e) {
      debugPrint('Error setting token: $e');
    }
  }

  Future<String?> getToken() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('x-auth-token');
    try {
      if (token == null) debugPrint('No token found');
      debugPrint('Token retrieved: $token');
    } catch (e) {
      debugPrint('Error retrieving token: $e');
    }
    return token;
  }
}
