import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/track.dart';

/// Wrapper sobre o Cloud Firestore para as colecoes por usuario (bonus RF06,
/// SDD §6.3): `users/{uid}/{colecao}/{trackId}` -> `Track` serializada. As
/// listas ficam sob o `uid` autenticado (RN07).
class FirestoreService {
  FirestoreService(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> _collection(String name) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('Sem sessao ativa');
    return _firestore.collection('users').doc(uid).collection(name);
  }

  Future<List<Track>> getAll(String name) async {
    final snapshot = await _collection(name).get();
    return snapshot.docs.map((d) => Track.fromJson(d.data())).toList();
  }

  Future<void> add(String name, Track track) =>
      _collection(name).doc(track.id).set(track.toJson());

  Future<void> remove(String name, String id) =>
      _collection(name).doc(id).delete();
}
