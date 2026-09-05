import 'package:flutter/foundation.dart';

import '../models/track.dart';
import '../repositories/catalog_repository.dart';

/// Estado do catalogo (RF01). Mantem a lista **acumulada** de faixas e o
/// estado de paginacao — por isso e Provider, nao FutureBuilder (SDD §5.6).
class CatalogProvider extends ChangeNotifier {
  CatalogProvider(this._repository, {this.pageSize = 25});

  final CatalogRepository _repository;
  final int pageSize;

  final List<Track> _tracks = [];
  List<Track> get tracks => List.unmodifiable(_tracks);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  bool _hasMore = false;
  bool get hasMore => _hasMore;

  // Guarda qualquer erro (AppException ou inesperado) para a UI localizar a
  // mensagem via failure_mapper e nunca travar (RF09).
  Object? _error;
  Object? get error => _error;

  bool get isEmpty => _tracks.isEmpty;

  /// Primeira pagina (RF01). Reinicia o estado.
  Future<void> loadInitial() async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final page = await _repository.loadChart(index: 0, limit: pageSize);
      _tracks
        ..clear()
        ..addAll(page.tracks);
      _hasMore = page.hasMore;
    } catch (e) {
      _error = e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Anexa a proxima pagina — nunca substitui a lista (RN05).
  Future<void> loadMore() async {
    if (_isLoadingMore || _isLoading || !_hasMore) return;
    _isLoadingMore = true;
    _error = null;
    notifyListeners();
    try {
      final page =
          await _repository.loadChart(index: _tracks.length, limit: pageSize);
      _tracks.addAll(page.tracks);
      _hasMore = page.hasMore;
    } catch (e) {
      _error = e;
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }
}
