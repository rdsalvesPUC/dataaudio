import 'package:dataaudio/core/error/app_exceptions.dart';
import 'package:dataaudio/l10n/app_localizations.dart';
import 'package:dataaudio/models/track.dart';
import 'package:dataaudio/models/track_page.dart';
import 'package:dataaudio/providers/catalog_provider.dart';
import 'package:dataaudio/repositories/catalog_repository.dart';
import 'package:dataaudio/views/catalog/catalog_view.dart';
import 'package:dataaudio/widgets/error_view.dart';
import 'package:dataaudio/widgets/track_grid_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

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

Widget _wrap(CatalogProvider provider) {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: ChangeNotifierProvider<CatalogProvider>.value(
      value: provider,
      child: const Scaffold(body: CatalogView()),
    ),
  );
}

void main() {
  late _MockCatalogRepository repo;

  setUp(() => repo = _MockCatalogRepository());

  testWidgets('RF01: renderiza a grade com as faixas carregadas',
      (tester) async {
    // Arrange
    when(() => repo.loadChart(index: 0, limit: any(named: 'limit'))).thenAnswer(
      (_) async =>
          TrackPage(tracks: [_track('1'), _track('2')], hasMore: false),
    );

    // Act
    await tester.pumpWidget(_wrap(CatalogProvider(repo)));
    await tester.pumpAndSettle();

    // Assert
    expect(find.byType(TrackGridItem), findsNWidgets(2));
    expect(find.text('Faixa 1'), findsOneWidget);
    expect(find.text('Artista 2'), findsOneWidget);
  });

  testWidgets('RF09: falha de rede mostra ErrorView com mensagem localizada',
      (tester) async {
    // Arrange
    when(() => repo.loadChart(index: 0, limit: any(named: 'limit')))
        .thenThrow(const NetworkException());

    // Act
    await tester.pumpWidget(_wrap(CatalogProvider(repo)));
    await tester.pumpAndSettle();

    // Assert
    expect(find.byType(ErrorView), findsOneWidget);
    expect(find.text('No connection. Check your internet.'), findsOneWidget);
  });

  testWidgets('RF09: falha no loadMore mostra erro + retry no tile (Codex #4)',
      (tester) async {
    // Arrange: primeira pagina OK, com mais paginas disponiveis
    when(() => repo.loadChart(index: 0, limit: any(named: 'limit'))).thenAnswer(
      (_) async => TrackPage(tracks: [_track('1')], hasMore: true),
    );
    await tester.pumpWidget(_wrap(CatalogProvider(repo)));
    await tester.pumpAndSettle();
    expect(find.text('Load more'), findsOneWidget);

    // Act: a proxima pagina falha
    when(() => repo.loadChart(index: 1, limit: any(named: 'limit')))
        .thenThrow(const NetworkException());
    await tester.tap(find.text('Load more'));
    await tester.pumpAndSettle();

    // Assert: o erro aparece no proprio tile, com botao de tentar novamente
    expect(find.text('No connection. Check your internet.'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
    // a lista ja carregada permanece (RN05)
    expect(find.byType(TrackGridItem), findsOneWidget);
  });
}
