import 'package:dataaudio/models/track.dart';
import 'package:dataaudio/providers/favorites_provider.dart';
import 'package:dataaudio/repositories/favorites_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockFavoritesRepository extends Mock implements FavoritesRepository {}

Track _track(String id) => Track(
      id: id,
      title: 'T$id',
      artistName: '',
      albumTitle: '',
      coverSmall: '',
      coverBig: '',
      durationSeconds: 0,
    );

void main() {
  late _MockFavoritesRepository repo;
  late FavoritesProvider provider;

  setUpAll(() => registerFallbackValue(_track('0')));

  setUp(() {
    repo = _MockFavoritesRepository();
    when(() => repo.add(any())).thenAnswer((_) async {});
    when(() => repo.remove(any())).thenAnswer((_) async {});
    provider = FavoritesProvider(repo);
  });

  test('load traz os favoritos persistidos', () async {
    when(() => repo.getAll())
        .thenAnswer((_) async => [_track('1'), _track('2')]);

    await provider.load();

    expect(provider.favorites, hasLength(2));
    expect(provider.isFavorite('1'), isTrue);
    expect(provider.isEmpty, isFalse);
  });

  test('toggle adiciona quando nao e favorito e persiste (RF04)', () async {
    // Arrange
    var notified = 0;
    provider.addListener(() => notified++);

    // Act
    await provider.toggle(_track('1'));

    // Assert
    expect(provider.isFavorite('1'), isTrue);
    verify(() => repo.add(any(that: isA<Track>()))).called(1);
    expect(notified, greaterThanOrEqualTo(1));
  });

  test('toggle remove quando ja e favorito e persiste', () async {
    when(() => repo.getAll()).thenAnswer((_) async => [_track('1')]);
    await provider.load();

    await provider.toggle(_track('1'));

    expect(provider.isFavorite('1'), isFalse);
    verify(() => repo.remove('1')).called(1);
  });

  test('estado reflete antes de a persistencia terminar (reatividade)', () async {
    // add com atraso: o estado em memoria deve mudar imediatamente
    when(() => repo.add(any())).thenAnswer(
      (_) => Future.delayed(const Duration(milliseconds: 50)),
    );

    final future = provider.toggle(_track('9'));

    expect(provider.isFavorite('9'), isTrue); // ja refletiu
    await future;
  });
}
