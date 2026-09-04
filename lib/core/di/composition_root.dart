import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/catalog_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../repositories/catalog_repository.dart';
import '../../repositories/deezer_catalog_repository.dart';
import '../../repositories/favorites_repository.dart';
import '../../repositories/local_favorites_repository.dart';
import '../../services/deezer_service.dart';
import '../../services/local_storage_service.dart';

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
  late final FavoritesRepository _favoritesRepository =
      LocalFavoritesRepository(_storage);

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Repositorio exposto para leituras pontuais via FutureBuilder
        // (ex.: a tela de detalhe, RF03/ADR-0003).
        Provider<CatalogRepository>.value(value: _catalogRepository),
        ChangeNotifierProvider(
          create: (_) => CatalogProvider(_catalogRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => FavoritesProvider(_favoritesRepository)..load(),
        ),
        // Ouvidas, Auth e Settings entram aqui nos proximos RF,
        // escolhendo Local* ou Cloud*/Firebase* conforme `useCloud`.
      ],
      child: widget.child,
    );
  }
}
