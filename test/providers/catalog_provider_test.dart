import 'package:dataaudio/core/error/app_exceptions.dart';
import 'package:dataaudio/models/track.dart';
import 'package:dataaudio/models/track_page.dart';
import 'package:dataaudio/providers/catalog_provider.dart';
import 'package:dataaudio/repositories/catalog_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockCatalogRepository extends Mock implements CatalogRepository {}

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
  late _MockCatalogRepository repo;
  late CatalogProvider provider;

  setUp(() {
    repo = _MockCatalogRepository();
    provider = CatalogProvider(repo, pageSize: 2);
  });

  group('loadInitial (RF01)', () {
    test('caminho feliz preenche a lista e define hasMore', () async {
      // Arrange
      when(() => repo.loadChart(index: 0, limit: 2)).thenAnswer(
        (_) async => TrackPage(tracks: [_track('1'), _track('2')], hasMore: true),
      );

      // Act
      await provider.loadInitial();

      // Assert
      expect(provider.tracks, hasLength(2));
      expect(provider.hasMore, isTrue);
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
    });

    test('notifica ao iniciar e ao terminar', () async {
      when(() => repo.loadChart(index: 0, limit: 2)).thenAnswer(
        (_) async => const TrackPage(tracks: [], hasMore: false),
      );
      var notifications = 0;
      provider.addListener(() => notifications++);

      await provider.loadInitial();

      expect(notifications, 2); // inicio (loading=true) + fim (loading=false)
    });

    test('erro de rede e capturado e exposto (RF09)', () async {
      when(() => repo.loadChart(index: 0, limit: 2))
          .thenThrow(const NetworkException());

      await provider.loadInitial();

      expect(provider.error, isA<NetworkException>());
      expect(provider.tracks, isEmpty);
      expect(provider.isLoading, isFalse);
    });
  });

  group('loadMore (RN05 — estende, nao substitui)', () {
    setUp(() {
      when(() => repo.loadChart(index: 0, limit: 2)).thenAnswer(
        (_) async => TrackPage(tracks: [_track('1'), _track('2')], hasMore: true),
      );
    });

    test('anexa a proxima pagina usando o index correto', () async {
      // Arrange
      await provider.loadInitial();
      when(() => repo.loadChart(index: 2, limit: 2)).thenAnswer(
        (_) async => TrackPage(tracks: [_track('3'), _track('4')], hasMore: false),
      );

      // Act
      await provider.loadMore();

      // Assert
      expect(provider.tracks.map((t) => t.id), ['1', '2', '3', '4']);
      expect(provider.hasMore, isFalse);
      verify(() => repo.loadChart(index: 2, limit: 2)).called(1);
    });

    test('nao chama o repositorio quando nao ha mais paginas', () async {
      await provider.loadInitial();
      when(() => repo.loadChart(index: 2, limit: 2)).thenAnswer(
        (_) async => const TrackPage(tracks: [], hasMore: false),
      );
      await provider.loadMore(); // hasMore vira false aqui
      clearInteractions(repo);

      await provider.loadMore(); // deve ser no-op

      verifyNever(() => repo.loadChart(index: any(named: 'index'), limit: any(named: 'limit')));
    });
  });
}
