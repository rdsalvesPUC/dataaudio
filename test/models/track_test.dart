import 'package:dataaudio/models/track.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Track.fromJson', () {
    test('interpreta o JSON cru da Deezer (artista/album aninhados)', () {
      // Arrange
      final json = {
        'id': 3135556,
        'title': 'Harder, Better, Faster, Stronger',
        'preview': 'https://cdn.deezer.com/preview.mp3',
        'duration': 224,
        'artist': {'name': 'Daft Punk'},
        'album': {
          'title': 'Discovery',
          'cover_medium': 'https://cdn.deezer.com/cover_medium.jpg',
          'cover_big': 'https://cdn.deezer.com/cover_big.jpg',
        },
      };

      // Act
      final track = Track.fromJson(json);

      // Assert
      expect(track.id, '3135556');
      expect(track.title, 'Harder, Better, Faster, Stronger');
      expect(track.artistName, 'Daft Punk');
      expect(track.albumTitle, 'Discovery');
      expect(track.coverSmall, 'https://cdn.deezer.com/cover_medium.jpg');
      expect(track.coverBig, 'https://cdn.deezer.com/cover_big.jpg');
      expect(track.previewUrl, 'https://cdn.deezer.com/preview.mp3');
      expect(track.durationSeconds, 224);
    });

    test('campos ausentes nao quebram e viram vazio/null (RN06)', () {
      // Arrange: faixa sem album, sem preview, sem duracao
      final json = {'id': 1, 'title': 'Sem capa', 'artist': {'name': 'Fulano'}};

      // Act
      final track = Track.fromJson(json);

      // Assert
      expect(track.coverBig, '');
      expect(track.coverSmall, '');
      expect(track.albumTitle, '');
      expect(track.previewUrl, isNull);
      expect(track.durationSeconds, 0);
    });

    test('preview vazio da Deezer vira null', () {
      final track = Track.fromJson({'id': 2, 'title': 't', 'preview': ''});
      expect(track.previewUrl, isNull);
    });
  });

  group('round-trip de persistencia (formato plano)', () {
    test('toJson e fromJson preservam todos os campos', () {
      // Arrange
      const original = Track(
        id: '42',
        title: 'Titulo',
        artistName: 'Artista',
        albumTitle: 'Album',
        coverSmall: 'small.jpg',
        coverBig: 'big.jpg',
        previewUrl: 'preview.mp3',
        durationSeconds: 180,
      );

      // Act
      final restored = Track.fromJson(original.toJson());

      // Assert
      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.artistName, original.artistName);
      expect(restored.albumTitle, original.albumTitle);
      expect(restored.coverSmall, original.coverSmall);
      expect(restored.coverBig, original.coverBig);
      expect(restored.previewUrl, original.previewUrl);
      expect(restored.durationSeconds, original.durationSeconds);
    });
  });

  group('igualdade', () {
    test('duas faixas com o mesmo id sao iguais (Set de favoritos)', () {
      const a = Track(
        id: '1', title: 'A', artistName: '', albumTitle: '',
        coverSmall: '', coverBig: '', durationSeconds: 0,
      );
      const b = Track(
        id: '1', title: 'B diferente', artistName: 'x', albumTitle: 'y',
        coverSmall: '', coverBig: '', durationSeconds: 99,
      );

      expect(a, equals(b));
      expect({a, b}.length, 1);
    });
  });
}
