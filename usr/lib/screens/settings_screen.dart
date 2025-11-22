import 'package:flutter/material.dart';
import '../services/theme_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = ThemeService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'APPEARANCE',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ListenableBuilder(
            listenable: themeService,
            builder: (context, _) {
              return Column(
                children: [
                  RadioListTile<ThemeMode>(
                    title: const Text('System Default'),
                    value: ThemeMode.system,
                    groupValue: themeService.themeMode,
                    onChanged: (value) {
                      if (value != null) themeService.setThemeMode(value);
                    },
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text('Light Mode'),
                    value: ThemeMode.light,
                    groupValue: themeService.themeMode,
                    onChanged: (value) {
                      if (value != null) themeService.setThemeMode(value);
                    },
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text('Dark Mode'),
                    value: ThemeMode.dark,
                    groupValue: themeService.themeMode,
                    onChanged: (value) {
                      if (value != null) themeService.setThemeMode(value);
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}