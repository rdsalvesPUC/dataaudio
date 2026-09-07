import 'dart:async';

import 'package:dataaudio/core/di/app_config.dart';
import 'package:dataaudio/core/error/app_exceptions.dart';
import 'package:dataaudio/core/navigation/app_routes.dart';
import 'package:dataaudio/l10n/app_localizations.dart';
import 'package:dataaudio/models/track.dart';
import 'package:dataaudio/models/track_page.dart';
import 'package:dataaudio/providers/auth_provider.dart';
import 'package:dataaudio/providers/catalog_provider.dart';
import 'package:dataaudio/providers/favorites_provider.dart';
import 'package:dataaudio/providers/listened_provider.dart';
import 'package:dataaudio/repositories/catalog_repository.dart';
import 'package:dataaudio/views/detail/track_detail_view.dart';
import 'package:dataaudio/widgets/error_view.dart';
import 'package:dataaudio/widgets/loading_indicator.dart';
import 'package:dataaudio/widgets/track_grid_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import '../support/fakes.dart';

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

Widget _wrapDetail(
  Track track,
  CatalogRepository repo, {
  FavoritesProvider? favorites,
}) =>
    MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MultiProvider(
        providers: [
          Provider<CatalogRepository>.value(value: repo),
          ChangeNotifierProvider<FavoritesProvider>.value(
            value: favorites ?? FavoritesProvider(FakeFavoritesRepository()),
          ),
          ChangeNotifierProvider<ListenedProvider>(
            create: (_) => ListenedProvider(FakeListenedRepository()),
          ),
        ],
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
      // Rota /home e protegida (RN01): a sessao precisa estar ativa.
      final auth = AuthProvider(FakeAuthRepository());
      await auth.register('joao', '1234');

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<AppConfig>.value(value: const AppConfig(useCloud: false)),
            Provider<CatalogRepository>.value(value: repo),
            ChangeNotifierProvider(create: (_) => CatalogProvider(repo)),
            ChangeNotifierProvider(
              create: (_) => FavoritesProvider(FakeFavoritesRepository()),
            ),
            ChangeNotifierProvider(
              create: (_) => ListenedProvider(FakeListenedRepository()),
            ),
            ChangeNotifierProvider<AuthProvider>.value(value: auth),
          ],
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            onGenerateRoute: AppRoutes.onGenerateRoute,
            initialRoute: AppRoutes.home, // pula o login neste teste de navegacao
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

  group('Favoritar no detalhe (RF04)', () {
    testWidgets('o coracao alterna o favorito e reflete no provider',
        (tester) async {
      // Arrange
      final track = _fullTrack();
      when(() => repo.trackDetail('1')).thenAnswer((_) async => track);
      final favorites = FavoritesProvider(FakeFavoritesRepository());

      await tester.pumpWidget(_wrapDetail(track, repo, favorites: favorites));
      await tester.pumpAndSettle();

      // Comeca como nao-favorito
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(favorites.isFavorite('1'), isFalse);

      // Act: toca no coracao
      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pumpAndSettle();

      // Assert: vira favorito (icone cheio) e reflete no provider
      expect(favorites.isFavorite('1'), isTrue);
      expect(find.byIcon(Icons.favorite), findsOneWidget);

      // Act: toca de novo para desfavoritar
      await tester.tap(find.byIcon(Icons.favorite));
      await tester.pumpAndSettle();

      // Assert: volta a nao-favorito
      expect(favorites.isFavorite('1'), isFalse);
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

    testWidgets(
        'favorita a faixa resolvida (completa), nao a parcial da rota (Codex #4)',
        (tester) async {
      // Arrange: a rota traz uma faixa parcial; o detalhe resolve a completa
      const partial = Track(
        id: '1',
        title: 'Harder Better',
        artistName: 'Daft Punk',
        albumTitle: '', // parcial: sem album
        coverSmall: '',
        coverBig: '',
        durationSeconds: 0, // parcial: sem duracao
      );
      when(() => repo.trackDetail('1')).thenAnswer((_) async => _fullTrack());
      final favorites = FavoritesProvider(FakeFavoritesRepository());

      await tester.pumpWidget(_wrapDetail(partial, repo, favorites: favorites));
      await tester.pumpAndSettle(); // detalhe resolvido

      // Act: favorita depois de carregar
      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pumpAndSettle();

      // Assert: persistiu os dados completos, nao os da rota
      final saved = favorites.favorites.single;
      expect(saved.albumTitle, 'Discovery');
      expect(saved.durationSeconds, 224);
    });
  });
}
