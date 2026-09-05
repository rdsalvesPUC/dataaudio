import 'dart:convert';

import '../models/track.dart';
import '../services/local_storage_service.dart';
import 'listened_repository.dart';

/// Implementacao baseline do [ListenedRepository] sobre [LocalStorageService]
/// (RF06). Persiste a `Track` inteira como JSON, sob a chave `listened`.
class LocalListenedRepository implements ListenedRepository {
  LocalListenedRepository(this._storage);

  static const String _key = 'listened';

  final LocalStorageService _storage;

  @override
  Future<List<Track>> getAll() async => _read();

  @override
  Future<void> add(Track track) async {
    final list = _read();
    if (list.any((t) => t.id == track.id)) return;
    list.add(track);
    await _write(list);
  }

  @override
  Future<void> remove(String id) async {
    final list = _read()..removeWhere((t) => t.id == id);
    await _write(list);
  }

  List<Track> _read() => _storage
      .getStringList(_key)
      .map((s) => Track.fromJson(jsonDecode(s) as Map<String, dynamic>))
      .toList();

  Future<void> _write(List<Track> tracks) => _storage.setStringList(
        _key,
        tracks.map((t) => jsonEncode(t.toJson())).toList(),
      );
}
