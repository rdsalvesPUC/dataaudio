import 'package:flutter/foundation.dart';

/// Faixa de musica — item central do catalogo, dos favoritos e das ouvidas.
///
/// Imutavel. `fromJson`/`toJson` escritos a mao (sem codegen, ADR-0009).
/// `fromJson` e tolerante: le tanto o JSON *cru da Deezer* (artista/album
/// aninhados, chaves `preview`/`duration`/`cover_*`) quanto o formato *plano*
/// que persistimos localmente (chaves `artistName`, `coverBig`, ...). Isso
/// permite que Favoritos e Ouvidas funcionem offline (SDD §5.3/§6.2).
@immutable
class Track {
  const Track({
    required this.id,
    required this.title,
    required this.artistName,
    required this.albumTitle,
    required this.coverSmall,
    required this.coverBig,
    required this.durationSeconds,
    this.previewUrl,
  });

  final String id;
  final String title;
  final String artistName;
  final String albumTitle;
  final String coverSmall;
  final String coverBig;

  /// URL da previa de 30s; `null` quando a Deezer nao fornece.
  final String? previewUrl;
  final int durationSeconds;

  factory Track.fromJson(Map<String, dynamic> json) {
    final artist = json['artist'];
    final album = json['album'];

    String pick(String flatKey, dynamic nested) {
      final flat = json[flatKey];
      if (flat is String && flat.isNotEmpty) return flat;
      if (nested is String) return nested;
      return '';
    }

    final rawPreview = json['previewUrl'] ?? json['preview'];
    final preview = (rawPreview is String && rawPreview.isNotEmpty) ? rawPreview : null;

    final rawDuration = json['durationSeconds'] ?? json['duration'];
    final duration = rawDuration is int
        ? rawDuration
        : int.tryParse('${rawDuration ?? ''}') ?? 0;

    return Track(
      id: '${json['id']}',
      title: pick('title', json['title']),
      artistName: pick('artistName', artist is Map ? artist['name'] : null),
      albumTitle: pick('albumTitle', album is Map ? album['title'] : null),
      coverSmall: pick('coverSmall', album is Map ? album['cover_medium'] : null),
      coverBig: pick('coverBig', album is Map ? album['cover_big'] : null),
      previewUrl: preview,
      durationSeconds: duration,
    );
  }

  /// Formato plano, usado na persistencia local (shared_preferences).
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'artistName': artistName,
        'albumTitle': albumTitle,
        'coverSmall': coverSmall,
        'coverBig': coverBig,
        'previewUrl': previewUrl,
        'durationSeconds': durationSeconds,
      };

  @override
  bool operator ==(Object other) => other is Track && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
