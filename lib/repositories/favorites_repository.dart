import '../models/track.dart';

/// Contrato de favoritos (SDD §5.3). A mesma interface serve ao baseline
/// (local) e ao bonus (nuvem) — so muda a implementacao (ADR-0006).
abstract interface class FavoritesRepository {
  /// Todas as faixas favoritadas (a `Track` inteira, para funcionar offline).
  Future<List<Track>> getAll();

  /// Adiciona [track] aos favoritos (idempotente por id).
  Future<void> add(Track track);

  /// Remove a faixa de id [id] dos favoritos.
  Future<void> remove(String id);
}
