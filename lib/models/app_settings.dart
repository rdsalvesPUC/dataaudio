import 'package:flutter/material.dart';

/// Preferencias de personalizacao (PF01 tema / PF02 idioma). `locale` nulo =
/// seguir o idioma do sistema; `ThemeMode.system` = seguir o tema do sistema.
/// Serializado em `shared_preferences` sob a chave `settings` (SDD §6.2).
@immutable
class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.locale,
  });

  final ThemeMode themeMode;
  final Locale? locale;

  AppSettings copyWith({ThemeMode? themeMode, Locale? locale, bool? clearLocale}) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      locale: (clearLocale ?? false) ? null : (locale ?? this.locale),
    );
  }

  Map<String, dynamic> toJson() => {
        'themeMode': themeMode.name,
        'localeCode': locale?.languageCode ?? '',
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    final code = (json['localeCode'] as String?) ?? '';
    return AppSettings(
      themeMode: ThemeMode.values.firstWhere(
        (m) => m.name == json['themeMode'],
        orElse: () => ThemeMode.system,
      ),
      locale: code.isEmpty ? null : Locale(code),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.themeMode == themeMode &&
      other.locale?.languageCode == locale?.languageCode;

  @override
  int get hashCode => Object.hash(themeMode, locale?.languageCode);
}
