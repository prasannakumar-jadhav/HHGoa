import 'package:flutter/material.dart';
import 'package:voxpilot/screens/main_shell.dart';

void main() {
  runApp(const VoxPilotApp());
}

class VoxPilotApp extends StatelessWidget {
  const VoxPilotApp({super.key});

  // Shared seed — deep indigo that reads well in both light and dark.
  static const Color _seed = Color(0xFF1A237E);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VoxPilot',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: ThemeMode.light,
      home: const MainShell(),
    );
  }

  static ThemeData _buildTheme(Brightness brightness) {
    final cs = ColorScheme.fromSeed(seedColor: _seed, brightness: brightness);

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      // ── Typography ────────────────────────────────────────────────────────
      // Let Material 3 generate the full scale; just adjust weights we rely on.
      textTheme: const TextTheme(
        displaySmall: TextStyle(fontWeight: FontWeight.w700),
        headlineMedium: TextStyle(fontWeight: FontWeight.w700),
        headlineSmall: TextStyle(fontWeight: FontWeight.w700),
        titleLarge: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        titleMedium: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        titleSmall: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        bodyLarge: TextStyle(fontSize: 16),
        bodyMedium: TextStyle(fontSize: 14),
        bodySmall: TextStyle(fontSize: 12),
        labelLarge: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        labelMedium: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
        labelSmall: TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
      ),
      // ── AppBar ────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: cs.onSurface,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: cs.onSurface, size: 22),
        actionsIconTheme: IconThemeData(color: cs.onSurface, size: 22),
      ),
      // ── Cards ─────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: cs.surfaceContainerLow,
      ),
      // ── Input fields ──────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cs.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.primary, width: 1.5),
        ),
        hintStyle: TextStyle(color: cs.onSurface.withValues(alpha: 0.45)),
      ),
      // ── Chips ─────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
      ),
      // ── Dividers ─────────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: cs.outlineVariant.withValues(alpha: 0.5),
        thickness: 1,
        space: 1,
      ),
      // ── FAB ──────────────────────────────────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      // ── Navigation bar ────────────────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        elevation: 2,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
