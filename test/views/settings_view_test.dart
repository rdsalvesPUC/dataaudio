import 'dart:ui' as ui;

import 'package:dataaudio/l10n/app_localizations.dart';
import 'package:dataaudio/models/app_settings.dart';
import 'package:dataaudio/providers/settings_provider.dart';
import 'package:dataaudio/views/settings/settings_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../support/fakes.dart';

Widget _wrap(SettingsProvider provider) => MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ChangeNotifierProvider<SettingsProvider>.value(
        value: provider,
        child: const Scaffold(body: SettingsView()),
      ),
    );

void main() {
  testWidgets('PF01: escolher "Dark" muda o tema no provider', (tester) async {
    final provider = SettingsProvider(FakeSettingsRepository());
    await tester.pumpWidget(_wrap(provider));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(provider.themeMode, ThemeMode.dark);
  });

  testWidgets('PF02: escolher "English" muda o idioma no provider',
      (tester) async {
    final provider = SettingsProvider(FakeSettingsRepository());
    await tester.pumpWidget(_wrap(provider));
    await tester.pumpAndSettle();

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(provider.locale?.languageCode, 'en');
  });

  testWidgets('mostra as secoes de tema e idioma', (tester) async {
    final provider = SettingsProvider(FakeSettingsRepository());
    await tester.pumpWidget(_wrap(provider));
    await tester.pumpAndSettle();

    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Follow system'), findsWidgets); // tema e idioma
  });

  testWidgets('a opcao ativa expoe estado selected a leitores de tela (Codex P2)',
      (tester) async {
    final handle = tester.ensureSemantics();
    final provider = SettingsProvider(
      FakeSettingsRepository(const AppSettings(themeMode: ThemeMode.dark)),
    )..load();
    await tester.pumpWidget(_wrap(provider));
    await tester.pumpAndSettle();

    bool isSelected(String label) => tester
        .getSemantics(
          find.ancestor(of: find.text(label), matching: find.byType(ListTile)),
        )
            .getSemanticsData()
            .flagsCollection
            .isSelected ==
        ui.Tristate.isTrue;

    // A opcao ativa (Dark) anuncia-se como selecionada; uma inativa (Light) nao.
    expect(isSelected('Dark'), isTrue);
    expect(isSelected('Light'), isFalse);
    handle.dispose();
  });
}
