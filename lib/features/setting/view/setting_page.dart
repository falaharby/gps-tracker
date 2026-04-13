import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/setting_provider.dart';

String _displayAccuracy(String key) {
  switch (key) {
    case 'high':
      return 'High accuracy';
    case 'balanced':
      return 'Balanced accuracy';
    case 'low':
      return 'Low power (low)';
    default:
      return key;
  }
}

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Location Settings',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Consumer<SettingProvider>(
                  builder: (context, settings, _) => Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.gps_fixed),
                        title: const Text('Accuracy'),
                        subtitle: Text(_displayAccuracy(settings.accuracy)),
                        trailing: DropdownButton<String>(
                          value: settings.accuracy,
                          items: const [
                            DropdownMenuItem(value: 'high', child: Text('High')),
                            DropdownMenuItem(value: 'balanced', child: Text('Balanced')),
                            DropdownMenuItem(value: 'low', child: Text('Low')),
                          ],
                          onChanged: (v) {
                            if (v != null) settings.setAccuracy(v);
                          },
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.timer),
                        title: const Text('Update Interval'),
                        subtitle: Text('Every ${settings.updateIntervalSeconds} seconds'),
                        trailing: DropdownButton<int>(
                          value: settings.updateIntervalSeconds,
                          items: const [
                            DropdownMenuItem(value: 5, child: Text('5s')),
                            DropdownMenuItem(value: 10, child: Text('10s')),
                            DropdownMenuItem(value: 30, child: Text('30s')),
                            DropdownMenuItem(value: 60, child: Text('1m')),
                          ],
                          onChanged: (v) {
                            if (v != null) settings.setUpdateInterval(v);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'About',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('App Version'),
                  subtitle: const Text('1.0.0'),
                  leading: const Icon(Icons.info),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
