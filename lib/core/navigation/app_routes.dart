import 'package:flutter/material.dart';

import '../../views/home/home_shell.dart';

/// Rotas nomeadas + `onGenerateRoute` (Navigator 1.0, ADR-0007).
/// `/login` e `/detail` serao adicionados com RF07 e RF02/RF03.
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
      default:
        return MaterialPageRoute(
          builder: (_) => const HomeShell(),
          settings: const RouteSettings(name: home),
        );
    }
  }
}
