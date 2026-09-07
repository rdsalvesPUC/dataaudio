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

  // Contador global monotonico de operacoes (nunca reinicia) + a ultima op de
  // cada faixa. Um rollback so se aplica se nenhuma operacao mais nova assumiu
  // aquela faixa E se um `load()` nao invalidou as pendencias no meio-tempo
  // (ex.: troca de usuario na nuvem).
  int _opCounter = 0;
  final Map<String, int> _lastOp = {};

  bool get isEmpty => _favorites.isEmpty;

  bool isFavorite(String id) => _favorites.any((t) => t.id == id);

  /// Carrega os favoritos persistidos (chamado na inicializacao). Se o storage
  /// estiver indisponivel/corrompido, segue com a lista vazia (RF09: sem travar).
  Future<void> load() async {
    // Invalida toggles pendentes: nenhum rollback antigo pode mexer no estado
    // recem-carregado (troca de usuario na nuvem).
    _lastOp.clear();
    try {
      final stored = await _repository.getAll();
      _favorites
        ..clear()
        ..addAll(stored);
    } catch (_) {
      // Sem sessao/storage indisponivel: lista vazia (nunca trava; e limpa os
      // dados do usuario anterior no modo nuvem apos logout).
      _favorites.clear();
    }
    notifyListeners();
  }

  /// Alterna o estado de favorito de [track] (RF04). Reflete na hora; se a
  /// persistencia falhar, reverte para manter memoria e storage consistentes.
  Future<void> toggle(Track track) async {
    final id = track.id;
    final op = ++_opCounter;
    _lastOp[id] = op;

    final wasFavorite = isFavorite(id);
    if (wasFavorite) {
      _favorites.removeWhere((t) => t.id == id);
    } else {
      _favorites.add(track);
    }
    notifyListeners();
    try {
      if (wasFavorite) {
        await _repository.remove(id);
      } else {
        await _repository.add(track);
      }
    } catch (_) {
      // Operacao obsoleta (toggle mais novo ou load() invalidou): nao reverte.
      if (_lastOp[id] != op) return;
      if (wasFavorite) {
        if (!isFavorite(id)) _favorites.add(track);
      } else {
        _favorites.removeWhere((t) => t.id == id);
      }
      notifyListeners();
    }
  }
}
