import 'package:dataaudio/core/error/app_exceptions.dart';
import 'package:dataaudio/repositories/local_auth_repository.dart';
import 'package:dataaudio/services/local_storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalAuthRepository repo;
  late LocalStorageService storage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = LocalStorageService(await SharedPreferences.getInstance());
    repo = LocalAuthRepository(storage);
  });

  test('sem sessao inicial', () async {
    expect(await repo.currentSession(), isNull);
  });

  test('register cria conta e abre sessao', () async {
    final user = await repo.register('joao', '1234');
    expect(user.username, 'joao');
    expect((await repo.currentSession())?.username, 'joao');
  });

  test('nao grava a senha em texto puro (armazena hash) - seguranca', () async {
    await repo.register('joao', 'segredo123');

    final raw = storage.getStringList('auth_users').join();
    expect(raw.contains('segredo123'), isFalse,
        reason: 'a senha nunca deve aparecer crua no storage');
  });

  test('register de usuario existente lanca AuthException', () async {
    await repo.register('joao', '1234');
    expect(
      () => repo.register('joao', 'outra'),
      throwsA(isA<AuthException>()),
    );
  });

  test('login com credenciais corretas abre sessao', () async {
    await repo.register('joao', '1234');
    await repo.logout();

    final user = await repo.login('joao', '1234');

    expect(user.username, 'joao');
    expect(await repo.currentSession(), isNotNull);
  });

  test('login com senha errada lanca AuthException', () async {
    await repo.register('joao', '1234');
    expect(
      () => repo.login('joao', 'errada'),
      throwsA(isA<AuthException>()),
    );
  });

  test('logout encerra a sessao', () async {
    await repo.register('joao', '1234');
    await repo.logout();
    expect(await repo.currentSession(), isNull);
  });

  test('sessao sobrevive a uma nova instancia do repositorio (RF07)', () async {
    await repo.register('joao', '1234');

    final repo2 = LocalAuthRepository(storage);

    expect((await repo2.currentSession())?.username, 'joao');
  });
}
