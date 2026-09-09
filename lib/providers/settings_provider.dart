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
    _themeMode = mode;
    notifyListeners();
    await _repository.save(AppSettings(themeMode: mode, locale: _locale));
  }

  Future<void> setLocale(Locale? locale) async {
    _locale = locale;
    notifyListeners();
    await _repository.save(AppSettings(themeMode: _themeMode, locale: locale));
  }
}
