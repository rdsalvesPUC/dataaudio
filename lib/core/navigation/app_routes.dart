import 'package:flutter/material.dart';

import '../../models/track.dart';
import '../../views/detail/track_detail_view.dart';
import '../../views/home/home_shell.dart';
import '../../views/login/login_view.dart';

/// Rotas nomeadas + `onGenerateRoute` (Navigator 1.0, ADR-0007). O app inicia
/// no login (guarda de acesso, RN01); login/logout usam `pushReplacement`.
abstract final class AppRoutes {
  // login e a raiz (sem expansao de rota inicial pelo Navigator).
  static const String login = '/';
  static const String home = '/home';
  static const String detail = '/detail';

  static const String initial = login;

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginView(),
          settings: settings,
        );
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
        // Rota desconhecida: cai no login (raiz), que decide o acesso.
        return MaterialPageRoute(
          builder: (_) => const LoginView(),
          settings: const RouteSettings(name: login),
        );
    }
  }

  static Route<dynamic> _fallbackHome() => MaterialPageRoute(
        builder: (_) => const HomeShell(),
        settings: const RouteSettings(name: home),
      );
}
