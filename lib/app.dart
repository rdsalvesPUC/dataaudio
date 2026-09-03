import 'package:flutter/material.dart';

import 'core/navigation/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';

/// Raiz visual do app: temas (PF01), internacionalizacao (PF02) e rotas
/// nomeadas (ADR-0007/0011). `themeMode` e `locale` passarao a ser dirigidos
/// pelo `SettingsProvider` quando ele existir.
class DataAudioApp extends StatelessWidget {
  const DataAudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (ctx) => AppLocalizations.of(ctx)!.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      initialRoute: AppRoutes.initial,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
