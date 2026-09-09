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

  /// Ultimo estado confirmado no disco — alvo do rollback quando a gravacao
  /// falha (nunca reverte para um valor que tambem nao estava persistido).
  AppSettings _persisted = const AppSettings();

  /// Sequencia monotonica das gravacoes. Uma gravacao so pode reverter o estado
  /// se ainda for a mais recente; uma falha "stale" (superada por um toque
  /// posterior) e ignorada, para nao apagar a selecao mais nova.
  int _writeSeq = 0;

  ThemeMode get themeMode => _themeMode;
  Locale? get locale => _locale;

  /// Carrega as preferencias persistidas (chamado na inicializacao).
  Future<void> load() async {
    final settings = await _repository.load();
    _persisted = settings;
    _themeMode = settings.themeMode;
    _locale = settings.locale;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    await _persist();
  }

  Future<void> setLocale(Locale? locale) async {
    _locale = locale;
    notifyListeners();
    await _persist();
  }

  /// Persiste o estado atual (otimista: a UI ja foi atualizada). Em caso de
  /// falha, so reverte se esta ainda for a gravacao mais recente — e reverte
  /// para o ultimo estado efetivamente persistido, nao para um intermediario.
  Future<void> _persist() async {
    final seq = ++_writeSeq;
    final desired = AppSettings(themeMode: _themeMode, locale: _locale);
    try {
      await _repository.save(desired);
      _persisted = desired;
    } catch (_) {
      if (seq != _writeSeq) return; // superada por um toque posterior
      _themeMode = _persisted.themeMode;
      _locale = _persisted.locale;
      notifyListeners();
    }
  }
}
