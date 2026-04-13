import 'package:flutter/foundation.dart';
import '../data/settings_repository.dart';

class SettingProvider extends ChangeNotifier {
  final SettingsRepository _service;

  // default values
  int updateIntervalSeconds = 10;
  String accuracy = 'high';
  bool backgroundTracking = false;

  SettingProvider({SettingsRepository? service}) : _service = service ?? SettingsRepository() {
    _load();
  }

  Future<void> _load() async {
    updateIntervalSeconds = await _service.getUpdateInterval();
    accuracy = await _service.getAccuracy();
    backgroundTracking = await _service.getBackgroundTracking();
    notifyListeners();
  }

  Future<void> setUpdateInterval(int seconds) async {
    updateIntervalSeconds = seconds;
    notifyListeners();
    await _service.setUpdateInterval(seconds);
  }

  Future<void> setAccuracy(String value) async {
    accuracy = value;
    notifyListeners();
    await _service.setAccuracy(value);
  }

  Future<void> setBackgroundTracking(bool enabled) async {
    backgroundTracking = enabled;
    notifyListeners();
    await _service.setBackgroundTracking(enabled);
  }
}
