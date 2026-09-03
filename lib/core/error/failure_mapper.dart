import '../../l10n/app_localizations.dart';
import 'app_exceptions.dart';

/// Converte uma excecao numa **mensagem amigavel e localizada** (RF09/ADR-0008).
/// A UI captura a excecao e chama isto — nunca exibe stack trace nem string crua.
String mapFailure(AppLocalizations l10n, Object? error) {
  return switch (error) {
    NetworkException() => l10n.errorNetwork,
    TimeoutException() => l10n.errorNetwork,
    NotFoundException() => l10n.errorNotFound,
    _ => l10n.errorGeneric,
  };
}
