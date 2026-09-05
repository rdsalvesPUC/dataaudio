import 'package:dataaudio/core/error/app_exceptions.dart';
import 'package:dataaudio/providers/auth_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

void main() {
  late FakeAuthRepository repo;

  setUp(() => repo = FakeAuthRepository());

  test('restoreSession sem sessao deixa nao-autenticado', () async {
    final provider = AuthProvider(repo);
    await provider.restoreSession();
    expect(provider.isAuthenticated, isFalse);
    expect(provider.isRestoring, isFalse);
  });

  test('register autentica', () async {
    final provider = AuthProvider(repo);
    await provider.register('joao', '1234');
    expect(provider.isAuthenticated, isTrue);
    expect(provider.user?.username, 'joao');
  });

  test('login invalido propaga AuthException e nao autentica', () async {
    final provider = AuthProvider(repo);
    await expectLater(
      provider.login('ninguem', 'x'),
      throwsA(isA<AuthException>()),
    );
    expect(provider.isAuthenticated, isFalse);
  });

  test('logout limpa a sessao', () async {
    final provider = AuthProvider(repo);
    await provider.register('joao', '1234');
    await provider.logout();
    expect(provider.isAuthenticated, isFalse);
  });

  test('restoreSession recupera sessao existente (login persistente)', () async {
    await repo.register('joao', '1234'); // ja deixa a sessao no repo

    final provider = AuthProvider(repo);
    await provider.restoreSession();

    expect(provider.isAuthenticated, isTrue);
    expect(provider.user?.username, 'joao');
  });
}
