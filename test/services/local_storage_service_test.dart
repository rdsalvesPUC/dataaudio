import 'package:dataaudio/services/local_storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('getStringList retorna vazio quando a chave nao existe', () async {
    // Arrange
    SharedPreferences.setMockInitialValues({});
    final storage = LocalStorageService(await SharedPreferences.getInstance());

    // Act & Assert
    expect(storage.getStringList('favorites'), isEmpty);
  });

  test('setStringList persiste e getStringList le de volta', () async {
    // Arrange
    SharedPreferences.setMockInitialValues({});
    final storage = LocalStorageService(await SharedPreferences.getInstance());

    // Act
    await storage.setStringList('favorites', ['a', 'b']);

    // Assert
    expect(storage.getStringList('favorites'), ['a', 'b']);
  });
}
