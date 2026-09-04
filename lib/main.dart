import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/di/composition_root.dart';

/// Bootstrap: inicializa a persistencia local e monta o composition root
/// (que decide local x nuvem e cria os providers) em volta do app.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    CompositionRoot(
      prefs: prefs,
      child: const DataAudioApp(),
    ),
  );
}
