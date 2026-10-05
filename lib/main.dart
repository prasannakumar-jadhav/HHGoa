import 'package:flutter/material.dart';
import 'package:voxpilot/screens/dashboard_screen.dart';

void main() {
  runApp(const VoxPilotApp());
}

class VoxPilotApp extends StatelessWidget {
  const VoxPilotApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF1A237E),
    );
    final darkColorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF1A237E),
      brightness: Brightness.dark,
    );

    return MaterialApp(
      title: 'VoxPilot',
      theme: ThemeData(useMaterial3: true, colorScheme: colorScheme),
      darkTheme: ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
      themeMode: ThemeMode.light,
      home: const DashboardScreen(),
    );
  }
}
