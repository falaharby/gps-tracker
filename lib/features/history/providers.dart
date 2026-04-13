import 'package:provider/provider.dart';
import 'package:gps_tracking_system/core/services/location_history_service.dart';
import 'viewmodel/history_controller.dart';

List<ChangeNotifierProvider> historyProviders() {
  return [
    ChangeNotifierProvider<HistoryController>(
      lazy: false,
      create: (context) => HistoryController(
        locationHistoryService: context.read<LocationHistoryService>(),
      )..init(),
    ),
  ];
}
