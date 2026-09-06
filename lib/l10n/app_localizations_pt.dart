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

  @override
  String get detailAlbum => 'Álbum';

  @override
  String get detailDuration => 'Duração';

  @override
  String get favoritesEmpty => 'Você ainda não tem favoritos.';

  @override
  String get favoriteAdd => 'Adicionar aos favoritos';

  @override
  String get favoriteRemove => 'Remover dos favoritos';

  @override
  String get loginTitle => 'Entrar';

  @override
  String get loginUsername => 'Usuário';

  @override
  String get loginEmail => 'E-mail';

  @override
  String get loginPassword => 'Senha';

  @override
  String get loginSignIn => 'Entrar';

  @override
  String get loginRegister => 'Criar conta';

  @override
  String get loginErrorEmpty => 'Preencha usuário e senha.';

  @override
  String get loginErrorInvalid => 'Usuário ou senha inválidos.';

  @override
  String get loginErrorExists => 'Este usuário já existe.';

  @override
  String get logout => 'Sair';

  @override
  String get listenedEmpty => 'Você ainda não marcou nada como ouvida.';

  @override
  String get listenedMark => 'Marcar como ouvida';

  @override
  String get listenedUnmark => 'Desmarcar ouvida';

  @override
  String get searchButton => 'Buscar';

  @override
  String get searchPrompt => 'Busque por faixas e artistas.';
}
