import 'package:flutter/foundation.dart';

import '../models/track.dart';
import '../repositories/listened_repository.dart';

/// Estado global das faixas Ouvidas (RF07). Analogo ao `FavoritesProvider`:
/// mantem a lista em memoria para reatividade e delega a persistencia ao
/// [ListenedRepository] (RF06).
class ListenedProvider extends ChangeNotifier {
  ListenedProvider(this._repository);

  final ListenedRepository _repository;

  final List<Track> _listened = [];
  List<Track> get listened => List.unmodifiable(_listened);

  bool get isEmpty => _listened.isEmpty;

  bool isListened(String id) => _listened.any((t) => t.id == id);

  Future<void> load() async {
    final stored = await _repository.getAll();
    _listened
      ..clear()
      ..addAll(stored);
    notifyListeners();
  }

  /// Alterna o estado de "ouvida" de [track] (RF07). Reflete na hora e persiste.
  Future<void> toggle(Track track) async {
    if (isListened(track.id)) {
      _listened.removeWhere((t) => t.id == track.id);
      notifyListeners();
      await _repository.remove(track.id);
    } else {
      _listened.add(track);
      notifyListeners();
      await _repository.add(track);
    }
  }
}
