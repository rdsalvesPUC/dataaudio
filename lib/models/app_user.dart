import 'package:flutter/foundation.dart';

/// Identidade de sessao (SDD §5.1). No baseline local o [id] coincide com o
/// [username]; com Firebase Auth (bonus) passa a ser o uid.
@immutable
class AppUser {
  const AppUser({required this.id, required this.username});

  final String id;
  final String username;

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: '${json['id']}',
        username: '${json['username']}',
      );

  Map<String, dynamic> toJson() => {'id': id, 'username': username};

  @override
  bool operator ==(Object other) =>
      other is AppUser && other.id == id && other.username == username;

  @override
  int get hashCode => Object.hash(id, username);
}
