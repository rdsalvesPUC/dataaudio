import 'package:dataaudio/l10n/app_localizations.dart';
import 'package:dataaudio/models/track.dart';
import 'package:dataaudio/providers/listened_provider.dart';
import 'package:dataaudio/views/listened/listened_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../support/fakes.dart';

Track _track(String id) => Track(
      id: id,
      title: 'Faixa $id',
      artistName: 'Artista $id',
      albumTitle: '',
      coverSmall: '',
      coverBig: '',
      durationSeconds: 0,
    );

Future<ListenedProvider> _provider([List<Track>? initial]) async {
  final p = ListenedProvider(FakeListenedRepository(initial));
  await p.load();
  return p;
}

Widget _wrap(ListenedProvider provider) => MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ChangeNotifierProvider<ListenedProvider>.value(
        value: provider,
        child: const Scaffold(body: ListenedView()),
      ),
    );

void main() {
  testWidgets('RF07: estado vazio mostra a mensagem localizada',
      (tester) async {
    final provider = await _provider();
    await tester.pumpWidget(_wrap(provider));
    await tester.pumpAndSettle();
    expect(find.text("You haven't marked anything as listened yet."),
        findsOneWidget);
  });

  testWidgets('RF07: lista as ouvidas; desmarcar atualiza na hora',
      (tester) async {
    final provider = await _provider([_track('1'), _track('2')]);
    await tester.pumpWidget(_wrap(provider));
    await tester.pumpAndSettle();
    expect(find.text('Faixa 1'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.check_circle).first);
    await tester.pumpAndSettle();

    expect(find.text('Faixa 1'), findsNothing);
    expect(find.text('Faixa 2'), findsOneWidget);
    expect(provider.isListened('1'), isFalse);
  });
}
