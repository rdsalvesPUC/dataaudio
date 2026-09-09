import 'package:flutter/material.dart';

import '../models/app_settings.dart';
import '../repositories/settings_repository.dart';

/// Estado de personalizacao (PF01 tema / PF02 idioma). Dirige
/// `MaterialApp.themeMode` e `locale`; a escolha reflete na hora e persiste
/// (RN08). `locale` nulo = seguir o idioma do sistema.
class SettingsProvider extends ChangeNotifier {
  SettingsProvider(this._repository);

  final SettingsRepository _repository;

  ThemeMode _themeMode = ThemeMode.system;
  Locale? _locale;

  ThemeMode get themeMode => _themeMode;
  Locale? get locale => _locale;

  /// Carrega as preferencias persistidas (chamado na inicializacao).
  Future<void> load() async {
    final settings = await _repository.load();
    _themeMode = settings.themeMode;
    _locale = settings.locale;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final previous = _themeMode;
    _themeMode = mode;
    notifyListeners();
    try {
      await _repository.save(AppSettings(themeMode: mode, locale: _locale));
    } catch (_) {
      // Persistencia falhou: reverte para nao exibir um valor nao salvo
      // (que voltaria ao antigo no proximo restart de qualquer forma).
      _themeMode = previous;
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale? locale) async {
    final previous = _locale;
    _locale = locale;
    notifyListeners();
    try {
      await _repository.save(AppSettings(themeMode: _themeMode, locale: locale));
    } catch (_) {
      _locale = previous;
      notifyListeners();
    }
  }
}
