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

  /// Geracao da ultima operacao por faixa: um rollback so se aplica se nenhum
  /// toggle mais novo assumiu aquela faixa (evita duplicar numa corrida).
  final Map<String, int> _opGen = {};

  bool get isEmpty => _listened.isEmpty;

  bool isListened(String id) => _listened.any((t) => t.id == id);

  /// Carrega as ouvidas persistidas. Se o storage falhar, segue com a lista
  /// vazia (RF09: sem travar).
  Future<void> load() async {
    try {
      final stored = await _repository.getAll();
      _listened
        ..clear()
        ..addAll(stored);
    } catch (_) {
      // Ignora: melhor uma lista vazia do que um crash na abertura.
    }
    notifyListeners();
  }

  /// Alterna o estado de "ouvida" de [track] (RF07). Reflete na hora; se a
  /// persistencia falhar, reverte para manter memoria e storage consistentes.
  Future<void> toggle(Track track) async {
    final id = track.id;
    final gen = (_opGen[id] ?? 0) + 1;
    _opGen[id] = gen;

    final wasListened = isListened(id);
    if (wasListened) {
      _listened.removeWhere((t) => t.id == id);
    } else {
      _listened.add(track);
    }
    notifyListeners();
    try {
      if (wasListened) {
        await _repository.remove(id);
      } else {
        await _repository.add(track);
      }
    } catch (_) {
      if (_opGen[id] != gen) return; // um toggle mais novo assumiu a faixa
      if (wasListened) {
        if (!isListened(id)) _listened.add(track);
      } else {
        _listened.removeWhere((t) => t.id == id);
      }
      notifyListeners();
    }
  }
}
