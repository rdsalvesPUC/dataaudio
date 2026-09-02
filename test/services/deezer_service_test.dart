import 'dart:async' as async_lib;
import 'dart:io';

import 'package:dataaudio/core/error/app_exceptions.dart';
import 'package:dataaudio/services/deezer_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class _MockClient extends Mock implements http.Client {}

void main() {
  late _MockClient client;
  late DeezerService service;
  final base = Uri.parse('https://api.deezer.com');

  setUpAll(() => registerFallbackValue(Uri()));

  setUp(() {
    client = _MockClient();
    service = DeezerService(client: client, baseUrl: base);
  });

  void stubGet(String body, {int status = 200}) {
    when(() => client.get(any()))
        .thenAnswer((_) async => http.Response(body, status));
  }

  const chartBody = '''
  {
    "data": [
      {"id": 1, "title": "T1", "preview": "p1", "duration": 100,
       "artist": {"name": "A1"},
       "album": {"title": "Al1", "cover_medium": "cm1", "cover_big": "cb1"}},
      {"id": 2, "title": "T2", "artist": {"name": "A2"}, "album": {"title": "Al2"}}
    ],
    "total": 100,
    "next": "https://api.deezer.com/chart/0/tracks?index=2"
  }''';

  group('fetchChart', () {
    test('mapeia faixas e hasMore=true quando ha next', () async {
      // Arrange
      stubGet(chartBody);

      // Act
      final page = await service.fetchChart(index: 0, limit: 25);

      // Assert
      expect(page.tracks, hasLength(2));
      expect(page.tracks.first.title, 'T1');
      expect(page.tracks.first.artistName, 'A1');
      expect(page.hasMore, isTrue);
    });

    test('monta a URL com index e limit corretos', () async {
      // Arrange
      stubGet(chartBody);

      // Act
      await service.fetchChart(index: 50, limit: 10);

      // Assert
      final captured =
          verify(() => client.get(captureAny())).captured.single as Uri;
      expect(captured.path, '/chart/0/tracks');
      expect(captured.queryParameters['index'], '50');
      expect(captured.queryParameters['limit'], '10');
    });

    test('hasMore=false quando nao ha next (ultima pagina)', () async {
      stubGet('{"data": [], "total": 0}');
      final page = await service.fetchChart();
      expect(page.hasMore, isFalse);
      expect(page.tracks, isEmpty);
    });
  });

  group('erros (RF09/ADR-0008)', () {
    test('404 -> NotFoundException', () async {
      stubGet('{}', status: 404);
      expect(service.fetchChart(), throwsA(isA<NotFoundException>()));
    });

    test('500 -> ApiException com statusCode', () async {
      stubGet('erro', status: 500);
      expect(
        service.fetchChart(),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'status', 500)),
      );
    });

    test('objeto error da Deezer (code 800) -> NotFoundException', () async {
      stubGet('{"error": {"type": "DataException", "message": "no data", "code": 800}}');
      expect(service.fetchChart(), throwsA(isA<NotFoundException>()));
    });

    test('SocketException -> NetworkException', () async {
      when(() => client.get(any())).thenThrow(const SocketException('offline'));
      expect(service.fetchChart(), throwsA(isA<NetworkException>()));
    });

    test('timeout -> TimeoutException', () async {
      when(() => client.get(any()))
          .thenThrow(async_lib.TimeoutException('demorou', const Duration(seconds: 15)));
      expect(service.fetchChart(), throwsA(isA<TimeoutException>()));
    });
  });

  group('search e fetchTrack', () {
    test('search monta q/index/limit', () async {
      stubGet(chartBody);
      await service.search('daft punk', index: 0, limit: 5);
      final captured =
          verify(() => client.get(captureAny())).captured.single as Uri;
      expect(captured.path, '/search');
      expect(captured.queryParameters['q'], 'daft punk');
      expect(captured.queryParameters['limit'], '5');
    });

    test('fetchTrack retorna uma Track', () async {
      stubGet('{"id": 7, "title": "Solo", "artist": {"name": "X"}, "duration": 60}');
      final track = await service.fetchTrack('7');
      expect(track.id, '7');
      expect(track.title, 'Solo');
      expect(track.durationSeconds, 60);
    });
  });
}
