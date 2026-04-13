import 'package:provider/provider.dart';
import 'viewmodel/setting_provider.dart';
import 'data/settings_repository.dart';

List<ChangeNotifierProvider> settingProviders() {
  return [
    ChangeNotifierProvider<SettingProvider>(
      create: (_) => SettingProvider(service: SettingsRepository()),
    ),
  ];
}
