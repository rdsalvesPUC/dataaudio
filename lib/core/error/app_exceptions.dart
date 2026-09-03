/// Hierarquia de excecoes do app (ADR-0008 / RF09).
///
/// Os *services* lancam estas excecoes tipadas; os *repositories* propagam;
/// a UI captura e usa `FailureMapper` para exibir uma mensagem amigavel e
/// localizada. Nunca se mostra stack trace ao usuario.
sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Falha de conectividade (sem rede, host inalcancavel, socket).
class NetworkException extends AppException {
  const NetworkException([super.message = 'Falha de rede']);
}

/// A requisicao expirou.
class TimeoutException extends AppException {
  const TimeoutException([super.message = 'Tempo esgotado']);
}

/// A API respondeu com um status de erro (>= 400).
class ApiException extends AppException {
  const ApiException(this.statusCode, [String message = 'Erro da API'])
      : super(message);
  final int statusCode;
}

/// Recurso inexistente (ex.: busca sem resultado, faixa removida).
class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Nao encontrado']);
}

/// Falha de autenticacao (credenciais invalidas, sessao expirada).
class AuthException extends AppException {
  const AuthException([super.message = 'Falha de autenticacao']);
}
