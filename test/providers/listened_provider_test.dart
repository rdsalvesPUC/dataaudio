import 'dart:async';

import 'package:dataaudio/models/track.dart';
import 'package:dataaudio/providers/listened_provider.dart';
import 'package:dataaudio/repositories/listened_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../support/fakes.dart';

class _MockListenedRepository extends Mock implements ListenedRepository {}

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
  test('load traz as ouvidas persistidas', () async {
    final provider =
        ListenedProvider(FakeListenedRepository([_track('1'), _track('2')]));
    await provider.load();
    expect(provider.listened, hasLength(2));
    expect(provider.isListened('1'), isTrue);
  });

  test('toggle marca e desmarca, refletindo na hora (RF07)', () async {
    final provider = ListenedProvider(FakeListenedRepository());

    await provider.toggle(_track('1'));
    expect(provider.isListened('1'), isTrue);

    await provider.toggle(_track('1'));
    expect(provider.isListened('1'), isFalse);
  });

  test('toggle notifica os ouvintes', () async {
    final provider = ListenedProvider(FakeListenedRepository());
    var notified = 0;
    provider.addListener(() => notified++);
    await provider.toggle(_track('1'));
    expect(notified, greaterThanOrEqualTo(1));
  });

  group('robustez (RF09, sem travar)', () {
    setUpAll(() => registerFallbackValue(_track('0')));

    test('load tolera falha do repositorio e fica vazio', () async {
      final repo = _MockListenedRepository();
      when(() => repo.getAll()).thenThrow(Exception('storage corrompido'));
      final provider = ListenedProvider(repo);

      await provider.load(); // nao deve lancar

      expect(provider.isEmpty, isTrue);
    });

    test('toggle reverte quando a persistencia falha', () async {
      final repo = _MockListenedRepository();
      when(() => repo.getAll()).thenAnswer((_) async => const []);
      when(() => repo.add(any())).thenThrow(Exception('falha ao gravar'));
      final provider = ListenedProvider(repo);

      await provider.toggle(_track('1')); // nao deve lancar

      expect(provider.isListened('1'), isFalse); // otimista revertido
    });

    test('toggles concorrentes na mesma faixa nao duplicam apos rollback '
        '(Codex P2)', () async {
      final repo = _MockListenedRepository();
      when(() => repo.getAll()).thenAnswer((_) async => [_track('1')]);
      final provider = ListenedProvider(repo);
      await provider.load();

      final removeCompleter = Completer<void>();
      when(() => repo.remove('1')).thenAnswer((_) => removeCompleter.future);
      final t1 = provider.toggle(_track('1')); // remove otimista (vai falhar)
      expect(provider.isListened('1'), isFalse);

      when(() => repo.add(any())).thenAnswer((_) async {});
      await provider.toggle(_track('1')); // add de volta, com sucesso
      expect(provider.isListened('1'), isTrue);

      removeCompleter.completeError(Exception('falha'));
      await t1;

      expect(provider.listened.where((t) => t.id == '1').length, 1);
      expect(provider.isListened('1'), isTrue);
    });
  });
}
