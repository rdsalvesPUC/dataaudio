import 'package:dataaudio/l10n/app_localizations.dart';
import 'package:dataaudio/models/track.dart';
import 'package:dataaudio/models/track_page.dart';
import 'package:dataaudio/providers/auth_provider.dart';
import 'package:dataaudio/providers/catalog_provider.dart';
import 'package:dataaudio/providers/favorites_provider.dart';
import 'package:dataaudio/providers/listened_provider.dart';
import 'package:dataaudio/repositories/catalog_repository.dart';
import 'package:dataaudio/views/home/home_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import '../support/fakes.dart';

class _MockCatalogRepository extends Mock implements CatalogRepository {}

Track _track(String id) => Track(
      id: id,
      title: 'Faixa $id',
      artistName: 'A$id',
      albumTitle: '',
      coverSmall: '',
      coverBig: '',
      durationSeconds: 0,
    );

void main() {
  testWidgets(
      'HomeShell mantem a CatalogView viva ao trocar de aba (IndexedStack, Codex #3)',
      (tester) async {
    // Arrange
    final repo = _MockCatalogRepository();
    when(() => repo.loadChart(index: 0, limit: any(named: 'limit'))).thenAnswer(
      (_) async => TrackPage(tracks: [_track('1')], hasMore: false),
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CatalogProvider(repo)),
          ChangeNotifierProvider(
            create: (_) => FavoritesProvider(FakeFavoritesRepository()),
          ),
          ChangeNotifierProvider(
            create: (_) => ListenedProvider(FakeListenedRepository()),
          ),
          ChangeNotifierProvider(
            create: (_) => AuthProvider(FakeAuthRepository()),
          ),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const HomeShell(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Act: vai para Favoritos e volta para o Catalogo (pelos rotulos das abas)
    await tester.tap(find.text('Favorites'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Catalog'));
    await tester.pumpAndSettle();

    // Assert: loadInitial rodou UMA vez so (a view nao foi recriada)
    verify(() => repo.loadChart(index: 0, limit: any(named: 'limit'))).called(1);
  });
}
