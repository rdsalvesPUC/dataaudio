import 'package:flutter/material.dart';

import '../../models/track.dart';
import '../../views/detail/track_detail_view.dart';
import '../../views/home/home_shell.dart';

/// Rotas nomeadas + `onGenerateRoute` (Navigator 1.0, ADR-0007).
/// `/login` sera adicionado com RF07.
abstract final class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String detail = '/detail';

  static const String initial = home;

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => const HomeShell(),
          settings: settings,
        );
      case detail:
        // RF02: a faixa selecionada vem como argumento da rota.
        final args = settings.arguments;
        if (args is Track) {
          return MaterialPageRoute(
            builder: (_) => TrackDetailView(track: args),
            settings: settings,
          );
        }
        return _fallbackHome();
      default:
        return _fallbackHome();
    }
  }

  static Route<dynamic> _fallbackHome() => MaterialPageRoute(
        builder: (_) => const HomeShell(),
        settings: const RouteSettings(name: home),
      );
}
