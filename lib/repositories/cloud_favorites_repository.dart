import '../models/track.dart';
import '../services/firestore_service.dart';
import 'favorites_repository.dart';

/// Favoritos na nuvem (bonus RF06) — mesma interface do baseline local
/// (ADR-0006), sobre o Firestore. Colecao `favorites` sob o usuario.
class CloudFavoritesRepository implements FavoritesRepository {
  CloudFavoritesRepository(this._firestore);

  static const String _collection = 'favorites';

  final FirestoreService _firestore;

  @override
  Future<List<Track>> getAll() => _firestore.getAll(_collection);

  @override
  Future<void> add(Track track) => _firestore.add(_collection, track);

  @override
  Future<void> remove(String id) => _firestore.remove(_collection, id);
}
