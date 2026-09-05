import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt'),
  ];

  /// Nome do aplicativo, exibido na barra de titulo.
  ///
  /// In pt, this message translates to:
  /// **'DataAudio'**
  String get appTitle;

  /// Rotulo da aba de catalogo.
  ///
  /// In pt, this message translates to:
  /// **'Catalogo'**
  String get navCatalog;

  /// Rotulo da aba de favoritos.
  ///
  /// In pt, this message translates to:
  /// **'Favoritos'**
  String get navFavorites;

  /// Rotulo da aba de faixas ouvidas.
  ///
  /// In pt, this message translates to:
  /// **'Ouvidas'**
  String get navListened;

  /// Rotulo da aba de ajustes.
  ///
  /// In pt, this message translates to:
  /// **'Ajustes'**
  String get navSettings;

  /// Botao que anexa a proxima pagina do catalogo (RF01).
  ///
  /// In pt, this message translates to:
  /// **'Carregar mais'**
  String get loadMore;

  /// Placeholder do campo de busca (RF08).
  ///
  /// In pt, this message translates to:
  /// **'Buscar faixas'**
  String get searchHint;

  /// Mensagem de erro generica (RF09).
  ///
  /// In pt, this message translates to:
  /// **'Algo deu errado. Tente novamente.'**
  String get errorGeneric;

  /// Erro de rede (RF09).
  ///
  /// In pt, this message translates to:
  /// **'Sem conexao. Verifique sua internet.'**
  String get errorNetwork;

  /// Recurso nao encontrado (busca sem resultado, RF08/RF09).
  ///
  /// In pt, this message translates to:
  /// **'Nada encontrado.'**
  String get errorNotFound;

  /// Botao para repetir uma operacao que falhou (RF09).
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get retry;

  /// Rotulo do campo album na tela de detalhe (RF03).
  ///
  /// In pt, this message translates to:
  /// **'Álbum'**
  String get detailAlbum;

  /// Rotulo do campo duracao na tela de detalhe (RF03).
  ///
  /// In pt, this message translates to:
  /// **'Duração'**
  String get detailDuration;

  /// Estado vazio da tela de favoritos (RF05).
  ///
  /// In pt, this message translates to:
  /// **'Você ainda não tem favoritos.'**
  String get favoritesEmpty;

  /// Rotulo de acessibilidade do botao ao favoritar (RF04/RF10).
  ///
  /// In pt, this message translates to:
  /// **'Adicionar aos favoritos'**
  String get favoriteAdd;

  /// Rotulo de acessibilidade do botao ao desfavoritar (RF04/RF10).
  ///
  /// In pt, this message translates to:
  /// **'Remover dos favoritos'**
  String get favoriteRemove;

  /// Titulo da tela de login (RF07).
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get loginTitle;

  /// Rotulo do campo usuario (RF07).
  ///
  /// In pt, this message translates to:
  /// **'Usuário'**
  String get loginUsername;

  /// Rotulo do campo senha (RF07).
  ///
  /// In pt, this message translates to:
  /// **'Senha'**
  String get loginPassword;

  /// Botao de autenticar (RF07).
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get loginSignIn;

  /// Botao de cadastrar (RF07).
  ///
  /// In pt, this message translates to:
  /// **'Criar conta'**
  String get loginRegister;

  /// Validacao de campos vazios no login (RF07/RF09).
  ///
  /// In pt, this message translates to:
  /// **'Preencha usuário e senha.'**
  String get loginErrorEmpty;

  /// Credenciais invalidas (RF07/RF09).
  ///
  /// In pt, this message translates to:
  /// **'Usuário ou senha inválidos.'**
  String get loginErrorInvalid;

  /// Cadastro de usuario ja existente (RF07/RF09).
  ///
  /// In pt, this message translates to:
  /// **'Este usuário já existe.'**
  String get loginErrorExists;

  /// Acao de encerrar a sessao (RF07).
  ///
  /// In pt, this message translates to:
  /// **'Sair'**
  String get logout;

  /// Estado vazio da tela de Ouvidas (RF07).
  ///
  /// In pt, this message translates to:
  /// **'Você ainda não marcou nada como ouvida.'**
  String get listenedEmpty;

  /// Rotulo de acessibilidade ao marcar como ouvida (RF07/RF10).
  ///
  /// In pt, this message translates to:
  /// **'Marcar como ouvida'**
  String get listenedMark;

  /// Rotulo de acessibilidade ao desmarcar ouvida (RF07/RF10).
  ///
  /// In pt, this message translates to:
  /// **'Desmarcar ouvida'**
  String get listenedUnmark;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
