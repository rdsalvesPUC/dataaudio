import 'package:dataaudio/models/track.dart';
import 'package:dataaudio/repositories/local_favorites_repository.dart';
import 'package:dataaudio/services/local_storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Track _track(String id) => Track(
      id: id,
      title: 'T$id',
      artistName: 'A$id',
      albumTitle: 'Al$id',
      coverSmall: 'cs$id',
      coverBig: 'cb$id',
      previewUrl: 'p$id',
      durationSeconds: 100 + int.parse(id),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalFavoritesRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    repo = LocalFavoritesRepository(
      LocalStorageService(await SharedPreferences.getInstance()),
    );
  });

  test('comeca vazio', () async {
    expect(await repo.getAll(), isEmpty);
  });

  test('add persiste a Track inteira (RF06) e getAll a recupera', () async {
    // Act
    await repo.add(_track('1'));
    final all = await repo.getAll();

    // Assert
    expect(all, hasLength(1));
    final t = all.single;
    expect(t.id, '1');
    expect(t.title, 'T1');
    expect(t.artistName, 'A1');
    expect(t.albumTitle, 'Al1');
    expect(t.coverBig, 'cb1');
    expect(t.previewUrl, 'p1');
    expect(t.durationSeconds, 101);
  });

  test('add e idempotente por id', () async {
    await repo.add(_track('1'));
    await repo.add(_track('1'));
    expect(await repo.getAll(), hasLength(1));
  });

  test('remove tira a faixa pelo id', () async {
    await repo.add(_track('1'));
    await repo.add(_track('2'));

    await repo.remove('1');

    final all = await repo.getAll();
    expect(all.map((t) => t.id), ['2']);
  });

  test('persistencia sobrevive a uma nova instancia do repositorio (RF06)',
      () async {
    // Arrange
    await repo.add(_track('7'));

    // Act: simula reabrir o app com uma nova instancia sobre o mesmo storage
    final repo2 = LocalFavoritesRepository(
      LocalStorageService(await SharedPreferences.getInstance()),
    );

    // Assert
    final all = await repo2.getAll();
    expect(all.single.id, '7');
  });
}
