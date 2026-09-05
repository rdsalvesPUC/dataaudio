import '../models/app_user.dart';

/// Contrato de autenticacao (SDD §5.3). Mesma interface para o baseline
/// (login local) e o bonus (Firebase Auth) — ADR-0006. Falhas de credencial
/// sobem como `AuthException` (ADR-0008).
abstract interface class AuthRepository {
  /// Sessao atual persistida, ou `null` se ninguem esta logado.
  Future<AppUser?> currentSession();

  /// Cria uma conta e ja abre a sessao. Lanca `AuthException` se o usuario
  /// ja existir.
  Future<AppUser> register(String username, String password);

  /// Autentica e abre a sessao. Lanca `AuthException` se as credenciais
  /// forem invalidas.
  Future<AppUser> login(String username, String password);

  /// Encerra a sessao atual.
  Future<void> logout();
}
