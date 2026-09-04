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

  /// Carrega os favoritos persistidos (chamado na inicializacao).
  Future<void> load() async {
    final stored = await _repository.getAll();
    _favorites
      ..clear()
      ..addAll(stored);
    notifyListeners();
  }

  /// Alterna o estado de favorito de [track] (RF04). Reflete na hora e persiste.
  Future<void> toggle(Track track) async {
    if (isFavorite(track.id)) {
      _favorites.removeWhere((t) => t.id == track.id);
      notifyListeners();
      await _repository.remove(track.id);
    } else {
      _favorites.add(track);
      notifyListeners();
      await _repository.add(track);
    }
  }
}
