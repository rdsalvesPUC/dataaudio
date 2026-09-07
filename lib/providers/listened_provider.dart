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

  // Contador global monotonico + a ultima op de cada faixa. Um rollback so se
  // aplica se nenhuma operacao mais nova assumiu a faixa e se um `load()` nao
  // invalidou as pendencias (ex.: troca de usuario na nuvem).
  int _opCounter = 0;
  final Map<String, int> _lastOp = {};

  bool get isEmpty => _listened.isEmpty;

  bool isListened(String id) => _listened.any((t) => t.id == id);

  /// Carrega as ouvidas persistidas. Se o storage falhar, segue com a lista
  /// vazia (RF09: sem travar).
  Future<void> load() async {
    // Invalida toggles pendentes (troca de usuario na nuvem).
    _lastOp.clear();
    try {
      final stored = await _repository.getAll();
      _listened
        ..clear()
        ..addAll(stored);
    } catch (_) {
      // Sem sessao/storage indisponivel: lista vazia (nunca trava; limpa os
      // dados do usuario anterior no modo nuvem apos logout).
      _listened.clear();
    }
    notifyListeners();
  }

  /// Alterna o estado de "ouvida" de [track] (RF07). Reflete na hora; se a
  /// persistencia falhar, reverte para manter memoria e storage consistentes.
  Future<void> toggle(Track track) async {
    final id = track.id;
    final op = ++_opCounter;
    _lastOp[id] = op;

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
      // Operacao obsoleta (toggle mais novo ou load() invalidou): nao reverte.
      if (_lastOp[id] != op) return;
      if (wasListened) {
        if (!isListened(id)) _listened.add(track);
      } else {
        _listened.removeWhere((t) => t.id == id);
      }
      notifyListeners();
    }
  }
}
