import '../models/track.dart';
import '../services/firestore_service.dart';
import 'listened_repository.dart';

/// Ouvidas na nuvem (bonus RF06) — mesma interface do baseline local, sobre o
/// Firestore. Colecao `listened` sob o usuario (independente dos favoritos,
/// RN03).
class CloudListenedRepository implements ListenedRepository {
  CloudListenedRepository(this._firestore);

  static const String _collection = 'listened';

  final FirestoreService _firestore;

  @override
  Future<List<Track>> getAll() => _firestore.getAll(_collection);

  @override
  Future<void> add(Track track) => _firestore.add(_collection, track);

  @override
  Future<void> remove(String id) => _firestore.remove(_collection, id);
}
