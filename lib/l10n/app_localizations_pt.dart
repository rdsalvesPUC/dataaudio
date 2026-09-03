// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'DataAudio';

  @override
  String get navCatalog => 'Catalogo';

  @override
  String get navFavorites => 'Favoritos';

  @override
  String get navListened => 'Ouvidas';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get loadMore => 'Carregar mais';

  @override
  String get searchHint => 'Buscar faixas';

  @override
  String get errorGeneric => 'Algo deu errado. Tente novamente.';

  @override
  String get errorNetwork => 'Sem conexao. Verifique sua internet.';

  @override
  String get errorNotFound => 'Nada encontrado.';

  @override
  String get retry => 'Tentar novamente';
}
