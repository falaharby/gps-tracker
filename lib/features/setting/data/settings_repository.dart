import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  static const _keyInterval = 'update_interval_seconds';
  static const _keyAccuracy = 'location_accuracy';
  static const _keyBackground = 'background_tracking';

  Future<int> getUpdateInterval() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getInt(_keyInterval) ?? 10;
  }

  Future<String> getAccuracy() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_keyAccuracy) ?? 'high';
  }

  Future<bool> getBackgroundTracking() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getBool(_keyBackground) ?? false;
  }

  Future<void> setUpdateInterval(int seconds) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(_keyInterval, seconds);
  }

  Future<void> setAccuracy(String value) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_keyAccuracy, value);
  }

  Future<void> setBackgroundTracking(bool enabled) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_keyBackground, enabled);
  }
}
