import 'dart:async';

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

  test(
      'escrita antiga que falha nao sobrescreve a selecao mais nova (Codex P2)',
      () async {
    // Arrange: a 1a gravacao (Dark) fica pendente e vai FALHAR; a 2a (Light) ok.
    // A view dispara os setters sem await (VoidCallback), entao eles se sobrepoem.
    final firstSave = Completer<void>();
    final results = <Future<void>>[
      firstSave.future, // save do Dark: controlado
      Future<void>.value(), // save do Light: sucesso imediato
    ];
    var call = 0;
    when(() => repo.save(any())).thenAnswer((_) => results[call++]);

    // Act: toca Dark e, sem esperar, toca Light; depois o save do Dark falha.
    final darkFuture = provider.setThemeMode(ThemeMode.dark);
    final lightFuture = provider.setThemeMode(ThemeMode.light);
    firstSave.completeError(Exception('storage indisponivel'));
    await Future.wait([darkFuture, lightFuture]);

    // Assert: Light (a mais nova, persistida) permanece — o rollback do Dark
    // stale nao pode reverter para System.
    expect(provider.themeMode, ThemeMode.light);
  });

  test(
      'sucesso stale nao sobrescreve o estado mais novo no disco (Codex P2)',
      () async {
    // Arrange: a 1a gravacao (Dark) fica pendente; a 2a (Light) e imediata.
    // Se as escritas nao forem serializadas, o Dark que completa depois grava
    // por ultimo e deixa disco/estado em Dark, embora a UI mostre Light.
    final darkSave = Completer<void>();
    final saved = <AppSettings>[];
    var call = 0;
    when(() => repo.save(any())).thenAnswer((invocation) {
      final s = invocation.positionalArguments.first as AppSettings;
      if (call++ == 0) {
        return darkSave.future.then((_) => saved.add(s)); // Dark: pendente
      }
      saved.add(s); // Light: sucesso imediato
      return Future<void>.value();
    });

    // Act: toca Dark e, sem esperar, Light; depois o save do Dark completa.
    final darkFuture = provider.setThemeMode(ThemeMode.dark);
    final lightFuture = provider.setThemeMode(ThemeMode.light);
    darkSave.complete();
    await Future.wait([darkFuture, lightFuture]);

    // Assert: a ultima gravacao no disco e a mais nova (Light), e o estado
    // exibido bate com o disco.
    expect(saved.last.themeMode, ThemeMode.light);
    expect(provider.themeMode, ThemeMode.light);
  });
}
