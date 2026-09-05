import 'package:dataaudio/core/navigation/app_routes.dart';
import 'package:dataaudio/l10n/app_localizations.dart';
import 'package:dataaudio/models/track_page.dart';
import 'package:dataaudio/providers/auth_provider.dart';
import 'package:dataaudio/providers/catalog_provider.dart';
import 'package:dataaudio/providers/favorites_provider.dart';
import 'package:dataaudio/providers/listened_provider.dart';
import 'package:dataaudio/repositories/catalog_repository.dart';
import 'package:dataaudio/views/home/home_shell.dart';
import 'package:dataaudio/views/login/login_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import '../support/fakes.dart';

class _MockCatalogRepository extends Mock implements CatalogRepository {}

Widget _app(GlobalKey<NavigatorState> navKey, AuthProvider auth) {
  final catalogRepo = _MockCatalogRepository();
  when(() => catalogRepo.loadChart(
        index: any(named: 'index'),
        limit: any(named: 'limit'),
      )).thenAnswer((_) async => const TrackPage(tracks: [], hasMore: false));

  return MultiProvider(
    providers: [
      Provider<CatalogRepository>.value(value: catalogRepo),
      ChangeNotifierProvider(create: (_) => CatalogProvider(catalogRepo)),
      ChangeNotifierProvider(
          create: (_) => FavoritesProvider(FakeFavoritesRepository())),
      ChangeNotifierProvider(
          create: (_) => ListenedProvider(FakeListenedRepository())),
      ChangeNotifierProvider<AuthProvider>.value(value: auth),
    ],
    child: MaterialApp(
      navigatorKey: navKey,
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      initialRoute: AppRoutes.login,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    ),
  );
}

void main() {
  testWidgets(
      'RN01: pushNamed(/home) sem sessao cai no login, nao monta a HomeShell '
      '(Codex P1)', (tester) async {
    // Arrange: usuario deslogado
    final navKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(_app(navKey, AuthProvider(FakeAuthRepository())));
    await tester.pumpAndSettle();

    // Act: um chamador qualquer navega direto para a rota protegida
    navKey.currentState!.pushNamed(AppRoutes.home);
    await tester.pumpAndSettle();

    // Assert: o guarda barrou — sem catalogo
    expect(find.byType(HomeShell), findsNothing);
    expect(find.byType(LoginView), findsWidgets);
  });

  testWidgets('com sessao, /home monta a HomeShell normalmente', (tester) async {
    // Arrange: usuario autenticado
    final auth = AuthProvider(FakeAuthRepository());
    await auth.register('joao', '1234');
    final navKey = GlobalKey<NavigatorState>();

    await tester.pumpWidget(_app(navKey, auth));
    await tester.pumpAndSettle();

    // Act
    navKey.currentState!.pushNamed(AppRoutes.home);
    await tester.pumpAndSettle();

    // Assert
    expect(find.byType(HomeShell), findsOneWidget);
  });
}
