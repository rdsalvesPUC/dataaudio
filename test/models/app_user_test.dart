import 'package:dataaudio/models/app_user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('round-trip de JSON preserva id e username', () {
    const user = AppUser(id: 'joao', username: 'joao');
    final restored = AppUser.fromJson(user.toJson());
    expect(restored, user);
  });

  test('igualdade por id + username', () {
    const a = AppUser(id: '1', username: 'a');
    const b = AppUser(id: '1', username: 'a');
    const c = AppUser(id: '1', username: 'b');
    expect(a, b);
    expect(a, isNot(c));
  });
}
