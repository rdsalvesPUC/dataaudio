import 'package:cloud_firestore/cloud_firestore.dart';
// firebase_auth tambem exporta um `AuthProvider`; escondemos para nao colidir
// com o nosso provider de mesmo nome.
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/auth_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/listened_provider.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/catalog_repository.dart';
import '../../repositories/cloud_favorites_repository.dart';
import '../../repositories/cloud_listened_repository.dart';
import '../../repositories/deezer_catalog_repository.dart';
import '../../repositories/favorites_repository.dart';
import '../../repositories/firebase_auth_repository.dart';
import '../../repositories/listened_repository.dart';
import '../../repositories/local_auth_repository.dart';
import '../../repositories/local_favorites_repository.dart';
import '../../repositories/local_listened_repository.dart';
import '../../services/deezer_service.dart';
import '../../services/firestore_service.dart';
import '../../services/local_storage_service.dart';
import 'app_config.dart';

/// Ponto unico de composicao (ADR-0006/SDD §10): decide as implementacoes
/// (local x nuvem) e monta o [MultiProvider] que embrulha o app. Trocar
/// [useCloud] reconfigura tudo sem tocar nas telas.
class CompositionRoot extends StatefulWidget {
  const CompositionRoot({
    super.key,
    required this.prefs,
    required this.child,
    this.useCloud = false,
  });

  final SharedPreferences prefs;
  final Widget child;
  final bool useCloud;

  @override
  State<CompositionRoot> createState() => _CompositionRootState();
}

class _CompositionRootState extends State<CompositionRoot> {
  late final http.Client _client = http.Client();
  late final DeezerService _deezer = DeezerService(client: _client);
  late final CatalogRepository _catalogRepository =
      DeezerCatalogRepository(_deezer);

  late final LocalStorageService _storage = LocalStorageService(widget.prefs);

  // So instanciado (via `late`) no modo nuvem — assim o baseline nao toca no
  // Firebase (que exige inicializacao) quando `useCloud` e false.
  late final FirestoreService _firestore =
      FirestoreService(FirebaseFirestore.instance, FirebaseAuth.instance);

  late final FavoritesRepository _favoritesRepository = widget.useCloud
      ? CloudFavoritesRepository(_firestore)
      : LocalFavoritesRepository(_storage);
  late final ListenedRepository _listenedRepository = widget.useCloud
      ? CloudListenedRepository(_firestore)
      : LocalListenedRepository(_storage);
  late final AuthRepository _authRepository = widget.useCloud
      ? FirebaseAuthRepository(FirebaseAuth.instance)
      : LocalAuthRepository(_storage);

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppConfig>.value(value: AppConfig(useCloud: widget.useCloud)),
        // Repositorio exposto para leituras pontuais via FutureBuilder
        // (ex.: a tela de detalhe, RF03/ADR-0003).
        Provider<CatalogRepository>.value(value: _catalogRepository),
        ChangeNotifierProvider(
          create: (_) => CatalogProvider(_catalogRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => FavoritesProvider(_favoritesRepository)..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => ListenedProvider(_listenedRepository)..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(_authRepository),
        ),
        // Settings (PF01/PF02) entra aqui em seguida; o bonus troca Local*
        // por Firebase*/Cloud* conforme `useCloud`.
      ],
      child: widget.child,
    );
  }
}
