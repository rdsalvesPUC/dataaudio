import '../models/track.dart';
import '../models/track_page.dart';
import '../services/deezer_service.dart';
import 'catalog_repository.dart';

/// Implementacao do [CatalogRepository] sobre a Deezer (SDD §5.3).
/// Fina por design: delega ao [DeezerService] e nao adiciona regra de negocio.
class DeezerCatalogRepository implements CatalogRepository {
  DeezerCatalogRepository(this._service);

  final DeezerService _service;

  @override
  Future<TrackPage> loadChart({int index = 0, int limit = 25}) =>
      _service.fetchChart(index: index, limit: limit);

  @override
  Future<TrackPage> search(String query, {int index = 0, int limit = 25}) =>
      _service.search(query, index: index, limit: limit);

  @override
  Future<Track> trackDetail(String id) => _service.fetchTrack(id);
}
