import 'track.dart';

/// Uma pagina de faixas retornada pela Deezer (catalogo ou busca).
///
/// `hasMore` deriva da presenca do campo `next` na resposta (SDD §6.4):
/// quando ha `next`, existem mais paginas a carregar (RF01 "Carregar mais").
class TrackPage {
  const TrackPage({required this.tracks, required this.hasMore});

  final List<Track> tracks;
  final bool hasMore;
}
