import 'package:flutter/material.dart';

import 'app.dart';
import 'core/di/composition_root.dart';

/// Bootstrap: monta o composition root (que decide local x nuvem e cria os
/// providers) em volta do app.
void main() {
  runApp(
    const CompositionRoot(
      child: DataAudioApp(),
    ),
  );
}
