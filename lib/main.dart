import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/di/composition_root.dart';

/// Bootstrap: inicializa a persistencia local e monta o composition root.
///
/// O bonus de nuvem (Firebase) e ativado com `--dart-define=USE_CLOUD=true` e
/// exige o Firebase configurado localmente (`flutterfire configure`, gera o
/// `google-services.json`). Sem a flag, o app roda no baseline local — sem
/// tocar no Firebase — e continua independente da configuracao de nuvem.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const useCloud = bool.fromEnvironment('USE_CLOUD');
  if (useCloud) {
    // Opcoes lidas do google-services.json (nao versionado).
    await Firebase.initializeApp();
  }

  final prefs = await SharedPreferences.getInstance();
  runApp(
    CompositionRoot(
      prefs: prefs,
      useCloud: useCloud,
      child: const DataAudioApp(),
    ),
  );
}
