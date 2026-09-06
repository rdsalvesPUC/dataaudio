import 'package:flutter/foundation.dart';

/// Configuracao decidida no composition root e exposta a UI. Hoje carrega
/// apenas [useCloud] (baseline local x bonus Firebase), que muda, por exemplo,
/// o rotulo do campo de login (usuario x e-mail).
@immutable
class AppConfig {
  const AppConfig({required this.useCloud});

  final bool useCloud;
}
