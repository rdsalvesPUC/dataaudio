import 'package:dataaudio/core/navigation/app_routes.dart';
import 'package:dataaudio/l10n/app_localizations.dart';
import 'package:dataaudio/providers/auth_provider.dart';
import 'package:dataaudio/views/login/login_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../support/fakes.dart';

/// App minimo: login na raiz; a rota home leva a um marcador simples (evita
/// montar a HomeShell e todos os seus providers).
Widget _app(AuthProvider auth) => ChangeNotifierProvider<AuthProvider>.value(
      value: auth,
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        initialRoute: AppRoutes.login,
        onGenerateRoute: (settings) {
          if (settings.name == AppRoutes.home) {
            return MaterialPageRoute(
              builder: (_) => const Scaffold(body: Text('HOME_MARKER')),
              settings: settings,
            );
          }
          return MaterialPageRoute(
            builder: (_) => const LoginView(),
            settings: settings,
          );
        },
      ),
    );

Future<void> _fillCredentials(
  WidgetTester tester,
  String user,
  String pass,
) async {
  await tester.enterText(find.byType(TextField).at(0), user);
  await tester.enterText(find.byType(TextField).at(1), pass);
}

void main() {
  testWidgets('RN01: sem login, mostra a tela de login (guarda de acesso)',
      (tester) async {
    await tester.pumpWidget(_app(AuthProvider(FakeAuthRepository())));
    await tester.pumpAndSettle();
    expect(find.byType(LoginView), findsOneWidget);
    expect(find.text('HOME_MARKER'), findsNothing);
  });

  testWidgets('RF07: criar conta autentica e avanca para o catalogo',
      (tester) async {
    await tester.pumpWidget(_app(AuthProvider(FakeAuthRepository())));
    await tester.pumpAndSettle();

    await _fillCredentials(tester, 'joao', '1234');
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();

    expect(find.text('HOME_MARKER'), findsOneWidget);
  });

  testWidgets('RF07/RF09: login invalido mostra erro e nao navega',
      (tester) async {
    await tester.pumpWidget(_app(AuthProvider(FakeAuthRepository())));
    await tester.pumpAndSettle();

    await _fillCredentials(tester, 'ninguem', 'errada');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Invalid username or password.'), findsOneWidget);
    expect(find.text('HOME_MARKER'), findsNothing);
  });

  testWidgets('RF07: campos vazios mostram validacao', (tester) async {
    await tester.pumpWidget(_app(AuthProvider(FakeAuthRepository())));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Fill in username and password.'), findsOneWidget);
  });

  testWidgets('RF07: sessao persistida avanca direto ao catalogo',
      (tester) async {
    // Arrange: repo ja com uma sessao aberta
    final repo = FakeAuthRepository();
    await repo.register('joao', '1234');

    // Act
    await tester.pumpWidget(_app(AuthProvider(repo)));
    await tester.pumpAndSettle();

    // Assert: pulou o login
    expect(find.text('HOME_MARKER'), findsOneWidget);
  });
}
