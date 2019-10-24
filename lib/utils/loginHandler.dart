import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  ///
  /// Instantiation of the SharedPreferences library
  ///
  static final String _csrf = null;

  static Future<String> getCsrf() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(_csrf) ?? null;
  }

  static Future<bool> setCsrf(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(_csrf, value);
  }

  static Future<String> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString("token") ?? null;
  }

  static setToken(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString("token", value);
  }

}