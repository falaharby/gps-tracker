import 'package:flutter/material.dart';

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
                ListTile(
                  title: const Text('Accuracy'),
                  subtitle: const Text('High accuracy'),
                  leading: const Icon(Icons.gps_fixed),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                ListTile(
                  title: const Text('Update Interval'),
                  subtitle: const Text('Every 10 seconds'),
                  leading: const Icon(Icons.timer),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const SizedBox(height: 24),
                Text(
                  'General Settings',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Dark Mode'),
                  leading: const Icon(Icons.dark_mode),
                  trailing: Switch(
                    value: false,
                    onChanged: (value) {},
                  ),
                  onTap: () {},
                ),
                ListTile(
                  title: const Text('Notifications'),
                  leading: const Icon(Icons.notifications),
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {},
                  ),
                  onTap: () {},
                ),
                const SizedBox(height: 24),
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
