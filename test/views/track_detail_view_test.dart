import 'dart:async';

import 'package:dataaudio/core/error/app_exceptions.dart';
import 'package:dataaudio/core/navigation/app_routes.dart';
import 'package:dataaudio/l10n/app_localizations.dart';
import 'package:dataaudio/models/track.dart';
import 'package:dataaudio/models/track_page.dart';
import 'package:dataaudio/providers/catalog_provider.dart';
import 'package:dataaudio/repositories/catalog_repository.dart';
import 'package:dataaudio/views/detail/track_detail_view.dart';
import 'package:dataaudio/widgets/error_view.dart';
import 'package:dataaudio/widgets/loading_indicator.dart';
import 'package:dataaudio/widgets/track_grid_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class _MockCatalogRepository extends Mock implements CatalogRepository {}

Track _fullTrack() => const Track(
      id: '1',
      title: 'Harder Better',
      artistName: 'Daft Punk',
      albumTitle: 'Discovery',
      coverSmall: '',
      coverBig: '',
      durationSeconds: 224,
    );

Widget _wrapDetail(Track track, CatalogRepository repo) => MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Provider<CatalogRepository>.value(
        value: repo,
        child: TrackDetailView(track: track),
      ),
    );

void main() {
  late _MockCatalogRepository repo;

  setUp(() => repo = _MockCatalogRepository());

  group('TrackDetailView (RF03)', () {
    testWidgets('mostra loading enquanto o detalhe carrega', (tester) async {
      // Arrange: future que nao completa
      final completer = Completer<Track>();
      when(() => repo.trackDetail(any())).thenAnswer((_) => completer.future);

      // Act
      await tester.pumpWidget(_wrapDetail(_fullTrack(), repo));
      await tester.pump();

      // Assert
      expect(find.byType(LoadingIndicator), findsOneWidget);
      completer.complete(_fullTrack()); // evita pendencia ao final
      await tester.pumpAndSettle();
    });

    testWidgets('caminho feliz mostra titulo, artista, album e duracao',
        (tester) async {
      // Arrange
      when(() => repo.trackDetail('1')).thenAnswer((_) async => _fullTrack());

      // Act
      await tester.pumpWidget(_wrapDetail(_fullTrack(), repo));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Harder Better'), findsWidgets); // titulo (AppBar + corpo)
      expect(find.text('Daft Punk'), findsOneWidget);
      expect(find.text('Discovery'), findsOneWidget);
      expect(find.text('Album'), findsOneWidget); // rotulo localizado (en)
      expect(find.text('3:44'), findsOneWidget); // 224s formatado
    });

    testWidgets('falha mostra ErrorView com mensagem localizada (RF09)',
        (tester) async {
      // Arrange: o repositorio e async, entao o erro vem como Future com falha
      when(() => repo.trackDetail('1'))
          .thenAnswer((_) async => throw const NetworkException());

      // Act
      await tester.pumpWidget(_wrapDetail(_fullTrack(), repo));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(ErrorView), findsOneWidget);
      expect(find.text('No connection. Check your internet.'), findsOneWidget);
    });

    testWidgets('campos ausentes nao quebram a tela (RF03)', (tester) async {
      // Arrange: sem album e sem duracao
      const partial = Track(
        id: '2',
        title: 'So o titulo',
        artistName: 'Alguem',
        albumTitle: '',
        coverSmall: '',
        coverBig: '',
        durationSeconds: 0,
      );
      when(() => repo.trackDetail('2')).thenAnswer((_) async => partial);

      // Act
      await tester.pumpWidget(_wrapDetail(partial, repo));
      await tester.pumpAndSettle();

      // Assert: titulo/artista aparecem; rotulos de album/duracao nao
      expect(find.text('So o titulo'), findsWidgets);
      expect(find.text('Alguem'), findsOneWidget);
      expect(find.text('Album'), findsNothing);
      expect(find.text('Duration'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('Navegacao catalogo -> detalhe (RF02)', () {
    testWidgets('tocar numa faixa abre a TrackDetailView correta',
        (tester) async {
      // Arrange
      final track = _fullTrack();
      when(() => repo.loadChart(index: 0, limit: any(named: 'limit')))
          .thenAnswer((_) async => TrackPage(tracks: [track], hasMore: false));
      when(() => repo.trackDetail('1')).thenAnswer((_) async => track);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<CatalogRepository>.value(value: repo),
            ChangeNotifierProvider(create: (_) => CatalogProvider(repo)),
          ],
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            onGenerateRoute: AppRoutes.onGenerateRoute,
            initialRoute: AppRoutes.initial,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(TrackGridItem), findsOneWidget);

      // Act
      await tester.tap(find.byType(TrackGridItem));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(TrackDetailView), findsOneWidget);
      expect(find.text('Discovery'), findsOneWidget); // detalhe renderizado
    });
  });
}
