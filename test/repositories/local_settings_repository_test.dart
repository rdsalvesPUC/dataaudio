import 'package:dataaudio/models/app_settings.dart';
import 'package:dataaudio/repositories/local_settings_repository.dart';
import 'package:dataaudio/services/local_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalSettingsRepository repo;
  late LocalStorageService storage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = LocalStorageService(await SharedPreferences.getInstance());
    repo = LocalSettingsRepository(storage);
  });

  test('padrao quando vazio: seguir o sistema', () async {
    final s = await repo.load();
    expect(s.themeMode, ThemeMode.system);
    expect(s.locale, isNull);
  });

  test('save + load preservam tema e idioma (PF01/PF02)', () async {
    await repo.save(
        const AppSettings(themeMode: ThemeMode.dark, locale: Locale('pt')));

    final s = await repo.load();
    expect(s.themeMode, ThemeMode.dark);
    expect(s.locale?.languageCode, 'pt');
  });

  test('persiste entre instancias (RN08)', () async {
    await repo.save(const AppSettings(themeMode: ThemeMode.light));
    final repo2 = LocalSettingsRepository(storage);
    expect((await repo2.load()).themeMode, ThemeMode.light);
  });
}
