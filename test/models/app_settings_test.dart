import 'package:dataaudio/models/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('round-trip: tema escuro + idioma en', () {
    const s = AppSettings(themeMode: ThemeMode.dark, locale: Locale('en'));
    final r = AppSettings.fromJson(s.toJson());
    expect(r.themeMode, ThemeMode.dark);
    expect(r.locale?.languageCode, 'en');
    expect(r, s);
  });

  test('padrao: seguir o sistema (locale nulo)', () {
    const s = AppSettings();
    final r = AppSettings.fromJson(s.toJson());
    expect(r.themeMode, ThemeMode.system);
    expect(r.locale, isNull);
  });

  test('valores desconhecidos caem no padrao', () {
    final r = AppSettings.fromJson({'themeMode': 'xyz', 'localeCode': ''});
    expect(r.themeMode, ThemeMode.system);
    expect(r.locale, isNull);
  });
}
