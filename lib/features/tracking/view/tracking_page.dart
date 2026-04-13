import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../viewmodel/tracking_controller.dart';
import '../../history/viewmodel/history_controller.dart';
import 'widgets/search_results_widget.dart';

class TrackingPage extends StatelessWidget {
  const TrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TrackingController>().initializeLocation();
    });

    return Scaffold(
      appBar: AppBar(title: const Text('GPS Tracker')),
      body: Consumer<TrackingController>(
        builder: (context, controller, _) {
          if (!controller.locationState.isLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              _buildMap(controller),
              _buildSearchBar(context, controller),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMap(TrackingController controller) {
    return FlutterMap(
      mapController: controller.mapController,
      options: MapOptions(
        initialCenter: controller.locationState.center,
        initialZoom: 15.0,
        onPositionChanged: (position, hasGesture) {
          if (hasGesture) {
            controller.mapController.move(position.center, position.zoom);
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.gps_tracking_system',
        ),
        // Polyline layer for active tracking
        if (controller.polyline != null)
          PolylineLayer(
            polylines: [controller.polyline!],
          ),
        MarkerLayer(
          markers: [
            // Current location marker
            if (controller.markers.isEmpty)
              Marker(
                width: 24,
                height: 24,
                point: controller.locationState.center,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withAlpha(153),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                ),
              ),
            // All tracking markers
            ...controller.markers,
            // Search result marker
            if (controller.searchResultState.marker != null)
              controller.searchResultState.marker!,
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context, TrackingController controller) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSearchInput(context, controller),
            SearchResultsWidget(
              onResultSelected: (lat, lon, name) {
                controller.selectSearchResult(lat, lon, name);
                controller.searchController.text = name;
                controller.mapController.move(LatLng(lat, lon), 15.0);
              },
            ),
            const SizedBox(height: 12),
            _buildTrackingButton(context, controller),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchInput(BuildContext context, TrackingController controller) {
    return Card(
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextField(
                controller: controller.searchController,
                enabled: !controller.searchResultState.hasSelected,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  hintText: 'Search location',
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 8.0,
                  ),
                  suffixIcon: controller.searchState.isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: Center(
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                        )
                      : null,
                  suffixIconConstraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                ),
                onSubmitted: (_) => _onSearch(context),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              controller.searchResultState.hasSelected
                  ? Icons.close
                  : Icons.search,
            ),
            onPressed: controller.searchResultState.hasSelected
                ? () => _clearSearch(context)
                : () => _onSearch(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingButton(
      BuildContext context, TrackingController controller) {
    return ElevatedButton.icon(
      onPressed: () => _toggleTracking(context, controller),
      icon: Icon(
        controller.isTracking ? Icons.stop : Icons.play_arrow,
        color: Colors.white,
      ),
      label: Text(
        controller.isTracking ? 'Stop Tracking' : 'Start Tracking',
        style: const TextStyle(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: controller.isTracking ? Colors.red : Colors.green,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Future<void> _onSearch(BuildContext context) async {
    final controller = context.read<TrackingController>();
    final query = controller.searchController.text.trim();
    if (query.isEmpty) return;
    await controller.search(query);
  }

  void _clearSearch(BuildContext context) {
    final controller = context.read<TrackingController>();
    controller.searchController.clear();
    controller.clearSearchResult();
    controller.mapController.move(
      controller.locationState.center,
      15.0,
    );
  }

  Future<void> _toggleTracking(
      BuildContext context, TrackingController controller) async {
    if (!controller.isTracking) {
      // Start tracking
      final granted = await requestPermissions();

      if (!granted) {
        _showPermissionDialog(context);
        return;
      }
      
      try {
        await controller.startTracking((newPos) {
          controller.mapController.move(newPos, 15.0);
          // Refresh history to show new tracking data
          context.read<HistoryController>().refresh();
          _showLocationSnackbar(context, newPos.latitude, newPos.longitude);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tracking started')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error starting tracking: $e')),
        );
      }
    } else {
      // Stop tracking
      try {
        await controller.stopTracking();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tracking stopped')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error stopping tracking: $e')),
        );
      }
    }
  }

  void _showLocationSnackbar(BuildContext context, double latitude, double longitude) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Lat: ${latitude.toStringAsFixed(6)}, Lon: ${longitude.toStringAsFixed(6)}',
          style: const TextStyle(color: Colors.white),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // 🔥 REQUEST PERMISSION BEFORE START
  Future<bool> requestPermissions() async {
    final notif = await Permission.notification.request();
    final location = await Permission.location.request();

    return notif.isGranted && location.isGranted;
  }

  void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permissions Required'),
          content: const Text(
            'Location permissions are required for tracking to work properly.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Back', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final status = await Permission.location.status;
                if (status.isPermanentlyDenied) {
                  await Geolocator.openAppSettings();
                } else {
                  requestPermissions();
                }
              },
              child: const Text('Request', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }
}

