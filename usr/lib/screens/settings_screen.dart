import 'package:flutter/material.dart';
import '../services/theme_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = ThemeService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              '外观',
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
                    title: const Text('跟随系统'),
                    value: ThemeMode.system,
                    groupValue: themeService.themeMode,
                    onChanged: (value) {
                      if (value != null) themeService.setThemeMode(value);
                    },
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text('浅色模式'),
                    value: ThemeMode.light,
                    groupValue: themeService.themeMode,
                    onChanged: (value) {
                      if (value != null) themeService.setThemeMode(value);
                    },
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text('深色模式'),
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
