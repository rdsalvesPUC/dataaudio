import 'package:dataaudio/core/error/app_exceptions.dart';
import 'package:dataaudio/core/navigation/app_routes.dart';
import 'package:dataaudio/l10n/app_localizations.dart';
import 'package:dataaudio/models/track.dart';
import 'package:dataaudio/models/track_page.dart';
import 'package:dataaudio/providers/auth_provider.dart';
import 'package:dataaudio/providers/favorites_provider.dart';
import 'package:dataaudio/providers/listened_provider.dart';
import 'package:dataaudio/repositories/catalog_repository.dart';
import 'package:dataaudio/views/detail/track_detail_view.dart';
import 'package:dataaudio/views/search/search_view.dart';
import 'package:dataaudio/widgets/error_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import '../support/fakes.dart';

class _MockCatalogRepository extends Mock implements CatalogRepository {}

Track _track(String id) => Track(
      id: id,
      title: 'Faixa $id',
      artistName: 'Artista $id',
      albumTitle: '',
      coverSmall: '',
      coverBig: '',
      durationSeconds: 0,
    );

Widget _wrap(CatalogRepository repo) => MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Provider<CatalogRepository>.value(
        value: repo,
        child: const SearchView(),
      ),
    );

Future<void> _search(WidgetTester tester, String term) async {
  await tester.enterText(find.byType(TextField), term);
  await tester.tap(find.widgetWithText(FilledButton, 'Search'));
  await tester.pumpAndSettle();
}

void main() {
  late _MockCatalogRepository repo;

  setUp(() => repo = _MockCatalogRepository());

  testWidgets('RF08: estado inicial tem campo, botao Buscar e mensagem',
      (tester) async {
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Search'), findsOneWidget);
    expect(find.text('Search for tracks and artists.'), findsOneWidget);
  });

  testWidgets('RF08: termo valido mostra os resultados', (tester) async {
    when(() => repo.search('daft',
            index: any(named: 'index'), limit: any(named: 'limit')))
        .thenAnswer((_) async =>
            TrackPage(tracks: [_track('1'), _track('2')], hasMore: false));

    await tester.pumpWidget(_wrap(repo));
    await _search(tester, 'daft');

    expect(find.text('Faixa 1'), findsOneWidget);
    expect(find.text('Artista 2'), findsOneWidget);
  });

  testWidgets('RF08: termo sem resultado mostra mensagem amigavel',
      (tester) async {
    when(() => repo.search(any(),
            index: any(named: 'index'), limit: any(named: 'limit')))
        .thenAnswer((_) async => const TrackPage(tracks: [], hasMore: false));

    await tester.pumpWidget(_wrap(repo));
    await _search(tester, 'zzzzz');

    expect(find.text('Nothing found.'), findsOneWidget);
  });

  testWidgets('RF09: falha na busca mostra ErrorView', (tester) async {
    when(() => repo.search(any(),
            index: any(named: 'index'), limit: any(named: 'limit')))
        .thenAnswer((_) async => throw const NetworkException());

    await tester.pumpWidget(_wrap(repo));
    await _search(tester, 'daft');

    expect(find.byType(ErrorView), findsOneWidget);
  });

  testWidgets('RF08/RF02: tocar num resultado navega ao detalhe',
      (tester) async {
    final track = _track('1');
    when(() => repo.search(any(),
            index: any(named: 'index'), limit: any(named: 'limit')))
        .thenAnswer((_) async => TrackPage(tracks: [track], hasMore: false));
    when(() => repo.trackDetail('1')).thenAnswer((_) async => track);
    final auth = AuthProvider(FakeAuthRepository());
    await auth.register('joao', '1234');

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<CatalogRepository>.value(value: repo),
          ChangeNotifierProvider(
              create: (_) => FavoritesProvider(FakeFavoritesRepository())),
          ChangeNotifierProvider(
              create: (_) => ListenedProvider(FakeListenedRepository())),
          ChangeNotifierProvider<AuthProvider>.value(value: auth),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          onGenerateRoute: AppRoutes.onGenerateRoute,
          home: const SearchView(),
        ),
      ),
    );

    await _search(tester, 'daft');
    await tester.tap(find.text('Faixa 1'));
    await tester.pumpAndSettle();

    expect(find.byType(TrackDetailView), findsOneWidget);
  });
}
