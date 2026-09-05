// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'DataAudio';

  @override
  String get navCatalog => 'Catalog';

  @override
  String get navFavorites => 'Favorites';

  @override
  String get navListened => 'Listened';

  @override
  String get navSettings => 'Settings';

  @override
  String get loadMore => 'Load more';

  @override
  String get searchHint => 'Search tracks';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorNetwork => 'No connection. Check your internet.';

  @override
  String get errorNotFound => 'Nothing found.';

  @override
  String get retry => 'Try again';

  @override
  String get detailAlbum => 'Album';

  @override
  String get detailDuration => 'Duration';

  @override
  String get favoritesEmpty => 'You have no favorites yet.';

  @override
  String get favoriteAdd => 'Add to favorites';

  @override
  String get favoriteRemove => 'Remove from favorites';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get loginUsername => 'Username';

  @override
  String get loginPassword => 'Password';

  @override
  String get loginSignIn => 'Sign in';

  @override
  String get loginRegister => 'Create account';

  @override
  String get loginErrorEmpty => 'Fill in username and password.';

  @override
  String get loginErrorInvalid => 'Invalid username or password.';

  @override
  String get loginErrorExists => 'This username already exists.';

  @override
  String get logout => 'Log out';

  @override
  String get listenedEmpty => 'You haven\'t marked anything as listened yet.';

  @override
  String get listenedMark => 'Mark as listened';

  @override
  String get listenedUnmark => 'Unmark listened';

  @override
  String get searchButton => 'Search';

  @override
  String get searchPrompt => 'Search for tracks and artists.';
}
