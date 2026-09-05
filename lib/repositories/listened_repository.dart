import '../models/track.dart';

/// Contrato das faixas Ouvidas (SDD §5.3). Lista independente dos Favoritos
/// (RN03). Mesma forma de interface — baseline local, bonus na nuvem.
abstract interface class ListenedRepository {
  Future<List<Track>> getAll();
  Future<void> add(Track track);
  Future<void> remove(String id);
}
