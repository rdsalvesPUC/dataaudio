import 'dart:async' as async_lib;
import 'dart:convert';
import 'dart:io' show SocketException;

import 'package:http/http.dart' as http;

import '../core/error/app_exceptions.dart';
import '../models/track.dart';
import '../models/track_page.dart';

/// Fala com a API publica da Deezer (SDD §5.2). Sem regra de negocio.
///
/// Recebe um [http.Client] por injecao — essencial para os testes (ADR-0009).
/// Traduz respostas HTTP em modelos e **lanca excecoes tipadas** em falha,
/// que sobem ate a UI para virar mensagem localizada (RF09/ADR-0008).
class DeezerService {
  DeezerService({
    http.Client? client,
    Uri? baseUrl,
    this.timeout = const Duration(seconds: 15),
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? Uri.parse('https://api.deezer.com');

  final http.Client _client;
  final Uri _baseUrl;
  final Duration timeout;

  /// RF01 — faixas do chart, paginadas por [index]/[limit].
  Future<TrackPage> fetchChart({int index = 0, int limit = 25}) {
    final uri = _baseUrl.replace(
      path: '/chart/0/tracks',
      queryParameters: {'index': '$index', 'limit': '$limit'},
    );
    return _getPage(uri);
  }

  /// RF08 — busca por [query], tambem paginada.
  Future<TrackPage> search(String query, {int index = 0, int limit = 25}) {
    final uri = _baseUrl.replace(
      path: '/search',
      queryParameters: {'q': query, 'index': '$index', 'limit': '$limit'},
    );
    return _getPage(uri);
  }

  /// RF03 — detalhe de uma faixa por id.
  Future<Track> fetchTrack(String id) async {
    final uri = _baseUrl.replace(path: '/track/$id');
    final json = await _getJson(uri);
    return Track.fromJson(json);
  }

  Future<TrackPage> _getPage(Uri uri) async {
    final json = await _getJson(uri);
    final data = (json['data'] as List?) ?? const [];
    final tracks = data
        .whereType<Map<String, dynamic>>()
        .map(Track.fromJson)
        .toList(growable: false);
    return TrackPage(tracks: tracks, hasMore: json.containsKey('next'));
  }

  /// GET + parsing + mapeamento de erros num so lugar.
  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    final http.Response response;
    try {
      response = await _client.get(uri).timeout(timeout);
    } on async_lib.TimeoutException {
      throw const TimeoutException();
    } on SocketException {
      throw const NetworkException();
    } on http.ClientException {
      throw const NetworkException();
    }

    if (response.statusCode == 404) {
      throw const NotFoundException();
    }
    if (response.statusCode >= 400) {
      throw ApiException(response.statusCode);
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const ApiException(200, 'Resposta inesperada da API');
    }
    // A Deezer responde 200 com um objeto `error` em falhas logicas.
    final error = decoded['error'];
    if (error is Map) {
      final code = error['code'];
      if (code == 800 || code == 4) throw const NotFoundException();
      throw ApiException(code is int ? code : 200, '${error['message']}');
    }
    return decoded;
  }
}
