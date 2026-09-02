import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Temas claro e escuro (Material 3). Dirigidos pelo `SettingsProvider` via
/// `MaterialApp.themeMode` (PF01/ADR-0011). As telas leem cores apenas de
/// `Theme.of(context)` — nada chumbado.
abstract final class AppTheme {
  static ThemeData get light => _base(Brightness.light);
  static ThemeData get dark => _base(Brightness.dark);

  static ThemeData _base(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      brightness: brightness,
    );
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
    );
  }
}
