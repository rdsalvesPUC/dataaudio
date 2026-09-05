import 'package:dataaudio/models/track.dart';
import 'package:dataaudio/repositories/local_listened_repository.dart';
import 'package:dataaudio/services/local_storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Track _track(String id) => Track(
      id: id,
      title: 'T$id',
      artistName: 'A$id',
      albumTitle: '',
      coverSmall: '',
      coverBig: '',
      durationSeconds: 0,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalListenedRepository repo;
  late LocalStorageService storage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = LocalStorageService(await SharedPreferences.getInstance());
    repo = LocalListenedRepository(storage);
  });

  test('add persiste e getAll recupera; idempotente por id', () async {
    await repo.add(_track('1'));
    await repo.add(_track('1'));
    final all = await repo.getAll();
    expect(all.map((t) => t.id), ['1']);
  });

  test('remove tira pelo id', () async {
    await repo.add(_track('1'));
    await repo.add(_track('2'));
    await repo.remove('1');
    expect((await repo.getAll()).map((t) => t.id), ['2']);
  });

  test('independente da chave de favoritos (RN03)', () async {
    await repo.add(_track('1'));
    // Chave distinta: nao colide com "favorites".
    expect(storage.getStringList('listened'), isNotEmpty);
    expect(storage.getStringList('favorites'), isEmpty);
  });

  test('sobrevive a uma nova instancia (RF06)', () async {
    await repo.add(_track('9'));
    final repo2 = LocalListenedRepository(storage);
    expect((await repo2.getAll()).single.id, '9');
  });
}
