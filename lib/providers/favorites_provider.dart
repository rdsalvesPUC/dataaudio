import 'package:flutter/foundation.dart';

import '../models/track.dart';
import '../repositories/favorites_repository.dart';

/// Estado global dos favoritos (RF04/RF05). Mantem a lista em memoria para
/// reatividade imediata e delega a persistencia ao [FavoritesRepository]
/// (RF06). Notifica os ouvintes a cada mudanca — a tela de Favoritos e o botao
/// de coracao reagem juntos.
class FavoritesProvider extends ChangeNotifier {
  FavoritesProvider(this._repository);

  final FavoritesRepository _repository;

  final List<Track> _favorites = [];
  List<Track> get favorites => List.unmodifiable(_favorites);

  bool get isEmpty => _favorites.isEmpty;

  bool isFavorite(String id) => _favorites.any((t) => t.id == id);

  /// Carrega os favoritos persistidos (chamado na inicializacao). Se o storage
  /// estiver indisponivel/corrompido, segue com a lista vazia (RF09: sem travar).
  Future<void> load() async {
    try {
      final stored = await _repository.getAll();
      _favorites
        ..clear()
        ..addAll(stored);
    } catch (_) {
      // Ignora: melhor uma lista vazia do que um crash na abertura.
    }
    notifyListeners();
  }

  /// Alterna o estado de favorito de [track] (RF04). Reflete na hora; se a
  /// persistencia falhar, reverte para manter memoria e storage consistentes.
  Future<void> toggle(Track track) async {
    final wasFavorite = isFavorite(track.id);
    if (wasFavorite) {
      _favorites.removeWhere((t) => t.id == track.id);
    } else {
      _favorites.add(track);
    }
    notifyListeners();
    try {
      if (wasFavorite) {
        await _repository.remove(track.id);
      } else {
        await _repository.add(track);
      }
    } catch (_) {
      if (wasFavorite) {
        _favorites.add(track);
      } else {
        _favorites.removeWhere((t) => t.id == track.id);
      }
      notifyListeners();
    }
  }
}
