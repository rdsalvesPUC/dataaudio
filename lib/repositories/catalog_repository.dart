import '../models/track.dart';
import '../models/track_page.dart';

/// Contrato de acesso ao catalogo (SDD §5.3). As views/providers dependem
/// desta *interface*, nunca do [DeezerService] concreto — a implementacao e
/// escolhida no composition root (ADR-0006).
abstract interface class CatalogRepository {
  /// RF01 — pagina do chart de faixas.
  Future<TrackPage> loadChart({int index = 0, int limit = 25});

  /// RF08 — busca paginada.
  Future<TrackPage> search(String query, {int index = 0, int limit = 25});

  /// RF03 — detalhe de uma faixa.
  Future<Track> trackDetail(String id);
}
