import 'package:dataaudio/core/theme/app_theme.dart';
import 'package:dataaudio/l10n/app_localizations.dart';
import 'package:dataaudio/models/track.dart';
import 'package:dataaudio/models/track_page.dart';
import 'package:dataaudio/providers/catalog_provider.dart';
import 'package:dataaudio/providers/favorites_provider.dart';
import 'package:dataaudio/providers/listened_provider.dart';
import 'package:dataaudio/repositories/catalog_repository.dart';
import 'package:dataaudio/views/catalog/catalog_view.dart';
import 'package:dataaudio/views/detail/track_detail_view.dart';
import 'package:dataaudio/widgets/track_grid_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import 'support/fakes.dart';

class _MockCatalogRepository extends Mock implements CatalogRepository {}

Track _detailTrack() => const Track(
      id: '1',
      title: 'Cadeira Cativa (Ao Vivo)',
      artistName: 'Zé Neto & Cristiano',
      albumTitle: 'Vocês & Deus, Vol. 1 (Ao Vivo no Rio de Janeiro)',
      coverSmall: '',
      coverBig: '',
      durationSeconds: 224,
    );

Widget _detailApp(
  Track track, {
  Brightness brightness = Brightness.light,
  double textScale = 1.0,
}) {
  final repo = _MockCatalogRepository();
  when(() => repo.trackDetail(track.id)).thenAnswer((_) async => track);
  return MaterialApp(
    theme: brightness == Brightness.light ? AppTheme.light : AppTheme.dark,
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(textScale)),
      child: child!,
    ),
    home: MultiProvider(
      providers: [
        Provider<CatalogRepository>.value(value: repo),
        ChangeNotifierProvider(
            create: (_) => FavoritesProvider(FakeFavoritesRepository())),
        ChangeNotifierProvider(
            create: (_) => ListenedProvider(FakeListenedRepository())),
      ],
      child: TrackDetailView(track: track),
    ),
  );
}

Track _track(String id) => Track(
      id: id,
      title: 'Faixa $id',
      artistName: 'Artista $id',
      albumTitle: '',
      coverSmall: '',
      coverBig: '',
      durationSeconds: 0,
    );

CatalogProvider _loadedProvider() {
  final repo = _MockCatalogRepository();
  when(() => repo.loadChart(
        index: any(named: 'index'),
        limit: any(named: 'limit'),
      )).thenAnswer((_) async => TrackPage(
        tracks: [_track('1'), _track('2'), _track('3'), _track('4')],
        hasMore: false,
      ));
  return CatalogProvider(repo);
}

Widget _catalogApp(
  CatalogProvider provider, {
  Brightness brightness = Brightness.light,
  double textScale = 1.0,
}) {
  return MaterialApp(
    theme: brightness == Brightness.light ? AppTheme.light : AppTheme.dark,
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(textScale)),
      child: child!,
    ),
    home: Scaffold(
      appBar: AppBar(title: const Text('Catalog')),
      body: ChangeNotifierProvider<CatalogProvider>.value(
        value: provider,
        child: const CatalogView(),
      ),
    ),
  );
}

void main() {
  testWidgets('RF10: catalogo tem alvos de toque rotulados', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_catalogApp(_loadedProvider()));
    await tester.pumpAndSettle();

    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    handle.dispose();
  });

  testWidgets('RF10: item da grade anuncia titulo+artista sem duplicar o '
      'titulo (capa decorativa)', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_catalogApp(_loadedProvider()));
    await tester.pumpAndSettle();

    final label = tester.getSemantics(find.byType(TrackGridItem).first).label;

    expect(label, contains('Artista 1'));
    // A capa nao deve repetir o titulo: "Faixa 1" aparece uma unica vez.
    expect('Faixa 1'.allMatches(label).length, 1, reason: 'label: $label');
    handle.dispose();
  });

  testWidgets('RF10: alvos de toque tem tamanho adequado (Android)',
      (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_catalogApp(_loadedProvider()));
    await tester.pumpAndSettle();

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    handle.dispose();
  });

  testWidgets('RF10: contraste adequado no tema claro', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
        _catalogApp(_loadedProvider(), brightness: Brightness.light));
    await tester.pumpAndSettle();

    await expectLater(tester, meetsGuideline(textContrastGuideline));
    handle.dispose();
  });

  testWidgets('RF10: contraste adequado no tema escuro', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
        _catalogApp(_loadedProvider(), brightness: Brightness.dark));
    await tester.pumpAndSettle();

    await expectLater(tester, meetsGuideline(textContrastGuideline));
    handle.dispose();
  });

  testWidgets('RF10: fonte grande (2x) nao estoura o layout do catalogo',
      (tester) async {
    await tester.pumpWidget(_catalogApp(_loadedProvider(), textScale: 2.0));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('RF10: detalhe tem contraste adequado (claro)', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
        _detailApp(_detailTrack(), brightness: Brightness.light));
    await tester.pumpAndSettle();

    await expectLater(tester, meetsGuideline(textContrastGuideline));
    handle.dispose();
  });

  testWidgets('RF10: detalhe tem contraste adequado (escuro)', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
        _detailApp(_detailTrack(), brightness: Brightness.dark));
    await tester.pumpAndSettle();

    await expectLater(tester, meetsGuideline(textContrastGuideline));
    handle.dispose();
  });

  testWidgets('RF10: detalhe tem alvos de toque rotulados', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_detailApp(_detailTrack()));
    await tester.pumpAndSettle();

    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    handle.dispose();
  });

  testWidgets('RF10: fonte grande (2x) nao estoura o detalhe (linhas de info)',
      (tester) async {
    await tester.pumpWidget(_detailApp(_detailTrack(), textScale: 2.0));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
