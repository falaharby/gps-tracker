import 'package:provider/provider.dart';
import 'data/tracking_repository.dart';
import 'viewmodel/tracking_controller.dart';
import '../../core/services/location_service.dart';
import '../../core/services/location_history_service.dart';

List<ChangeNotifierProvider> trackingProviders() {
  return [
    ChangeNotifierProvider<LocationService>(
      create: (_) => LocationService(),
    ),
    ChangeNotifierProvider<LocationHistoryService>(
      create: (_) => LocationHistoryService()..init(),
    ),
    ChangeNotifierProvider<TrackingController>(
      create: (context) => TrackingController(
        repository: TrackingRepository(),
        locationService: context.read<LocationService>(),
        locationHistoryService: context.read<LocationHistoryService>(),
      ),
    ),
  ];
}
