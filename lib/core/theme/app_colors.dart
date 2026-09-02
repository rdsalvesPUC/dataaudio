import 'package:flutter/material.dart';

/// Cores-semente do DataAudio. Todo o resto deriva daqui via
/// [ColorScheme.fromSeed] — nenhuma cor e usada chumbada nas telas (ADR-0010).
abstract final class AppColors {
  static const Color seed = Color(0xFF6750A4);
}
