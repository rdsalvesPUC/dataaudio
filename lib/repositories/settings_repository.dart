import '../models/app_settings.dart';

/// Contrato das preferencias de tema e idioma (SDD §5.3). Baseline local; a UI
/// depende desta interface, nao da implementacao.
abstract interface class SettingsRepository {
  Future<AppSettings> load();
  Future<void> save(AppSettings settings);
}
