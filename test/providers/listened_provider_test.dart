import 'package:dataaudio/models/track.dart';
import 'package:dataaudio/providers/listened_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

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
}
