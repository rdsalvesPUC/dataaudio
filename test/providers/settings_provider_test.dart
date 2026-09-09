import 'package:dataaudio/models/app_settings.dart';
import 'package:dataaudio/providers/settings_provider.dart';
import 'package:dataaudio/repositories/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late _MockSettingsRepository repo;
  late SettingsProvider provider;

  setUpAll(() => registerFallbackValue(const AppSettings()));

  setUp(() {
    repo = _MockSettingsRepository();
    when(() => repo.save(any())).thenAnswer((_) async {});
    when(() => repo.load()).thenAnswer((_) async => const AppSettings());
    provider = SettingsProvider(repo);
  });

  test('load traz as preferencias persistidas', () async {
    when(() => repo.load()).thenAnswer((_) async =>
        const AppSettings(themeMode: ThemeMode.dark, locale: Locale('en')));

    await provider.load();

    expect(provider.themeMode, ThemeMode.dark);
    expect(provider.locale?.languageCode, 'en');
  });

  test('setThemeMode reflete, notifica e persiste (PF01)', () async {
    var notified = 0;
    provider.addListener(() => notified++);

    await provider.setThemeMode(ThemeMode.dark);

    expect(provider.themeMode, ThemeMode.dark);
    expect(notified, greaterThanOrEqualTo(1));
    verify(() => repo.save(any(
        that: isA<AppSettings>()
            .having((s) => s.themeMode, 'themeMode', ThemeMode.dark)))).called(1);
  });

  test('setLocale reflete, notifica e persiste (PF02)', () async {
    await provider.setLocale(const Locale('pt'));

    expect(provider.locale?.languageCode, 'pt');
    verify(() => repo.save(any(
        that: isA<AppSettings>().having(
            (s) => s.locale?.languageCode, 'locale', 'pt')))).called(1);
  });

  test('setLocale(null) volta a seguir o sistema', () async {
    await provider.setLocale(const Locale('pt'));
    await provider.setLocale(null);
    expect(provider.locale, isNull);
  });

  test('setThemeMode faz rollback quando o save falha (Codex P2)', () async {
    // Arrange: escrita da preferencia indisponivel (ex.: storage falho)
    when(() => repo.save(any())).thenThrow(Exception('storage indisponivel'));

    // Act
    await provider.setThemeMode(ThemeMode.dark);

    // Assert: nao fica exibindo um valor que nao foi persistido — reverte ja
    expect(provider.themeMode, ThemeMode.system);
  });

  test('setLocale faz rollback quando o save falha (Codex P2)', () async {
    // Arrange
    when(() => repo.save(any())).thenThrow(Exception('storage indisponivel'));

    // Act
    await provider.setLocale(const Locale('pt'));

    // Assert
    expect(provider.locale, isNull);
  });
}
