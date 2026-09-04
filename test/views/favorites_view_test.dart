import 'package:dataaudio/l10n/app_localizations.dart';
import 'package:dataaudio/models/track.dart';
import 'package:dataaudio/providers/favorites_provider.dart';
import 'package:dataaudio/repositories/favorites_repository.dart';
import 'package:dataaudio/views/favorites/favorites_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _FakeFavoritesRepository implements FavoritesRepository {
  _FakeFavoritesRepository([List<Track>? initial]) {
    if (initial != null) _items.addAll(initial);
  }
  final List<Track> _items = [];
  @override
  Future<void> add(Track track) async {
    if (!_items.any((t) => t.id == track.id)) _items.add(track);
  }

  @override
  Future<List<Track>> getAll() async => List.of(_items);

  @override
  Future<void> remove(String id) async => _items.removeWhere((t) => t.id == id);
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

Future<FavoritesProvider> _provider([List<Track>? initial]) async {
  final p = FavoritesProvider(_FakeFavoritesRepository(initial));
  await p.load();
  return p;
}

Widget _wrap(FavoritesProvider provider) => MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ChangeNotifierProvider<FavoritesProvider>.value(
        value: provider,
        child: const Scaffold(body: FavoritesView()),
      ),
    );

void main() {
  testWidgets('RF05: estado vazio mostra a mensagem localizada',
      (tester) async {
    // Arrange
    final provider = await _provider();

    // Act
    await tester.pumpWidget(_wrap(provider));
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('You have no favorites yet.'), findsOneWidget);
  });

  testWidgets('RF05: lista os favoritos; remover atualiza na hora',
      (tester) async {
    // Arrange
    final provider = await _provider([_track('1'), _track('2')]);
    await tester.pumpWidget(_wrap(provider));
    await tester.pumpAndSettle();
    expect(find.text('Faixa 1'), findsOneWidget);
    expect(find.text('Faixa 2'), findsOneWidget);

    // Act: remove o primeiro pelo botao de coracao
    await tester.tap(find.byIcon(Icons.favorite).first);
    await tester.pumpAndSettle();

    // Assert: some da lista sem recarregar
    expect(find.text('Faixa 1'), findsNothing);
    expect(find.text('Faixa 2'), findsOneWidget);
    expect(provider.isFavorite('1'), isFalse);
  });
}
