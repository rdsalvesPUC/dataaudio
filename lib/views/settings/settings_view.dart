import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/settings_provider.dart';

/// Tela de Ajustes (PF01 tema / PF02 idioma). Cada escolha reflete na hora
/// (via `SettingsProvider` → `MaterialApp`) e persiste (RN08).
class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsProvider>();

    return ListView(
      children: [
        _SectionHeader(l10n.settingsTheme),
        _OptionTile(
          label: l10n.settingsFollowSystem,
          selected: settings.themeMode == ThemeMode.system,
          onTap: () =>
              context.read<SettingsProvider>().setThemeMode(ThemeMode.system),
        ),
        _OptionTile(
          label: l10n.settingsThemeLight,
          selected: settings.themeMode == ThemeMode.light,
          onTap: () =>
              context.read<SettingsProvider>().setThemeMode(ThemeMode.light),
        ),
        _OptionTile(
          label: l10n.settingsThemeDark,
          selected: settings.themeMode == ThemeMode.dark,
          onTap: () =>
              context.read<SettingsProvider>().setThemeMode(ThemeMode.dark),
        ),
        const Divider(),
        _SectionHeader(l10n.settingsLanguage),
        _OptionTile(
          label: l10n.settingsFollowSystem,
          selected: settings.locale == null,
          onTap: () => context.read<SettingsProvider>().setLocale(null),
        ),
        _OptionTile(
          label: l10n.settingsLangPt,
          selected: settings.locale?.languageCode == 'pt',
          onTap: () =>
              context.read<SettingsProvider>().setLocale(const Locale('pt')),
        ),
        _OptionTile(
          label: l10n.settingsLangEn,
          selected: settings.locale?.languageCode == 'en',
          onTap: () =>
              context.read<SettingsProvider>().setLocale(const Locale('en')),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        title,
        style: theme.textTheme.titleSmall
            ?.copyWith(color: theme.colorScheme.primary),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // `selected` marca o ListTile visualmente E expoe o estado `isSelected`
    // aos leitores de tela (TalkBack/VoiceOver anunciam a opcao ativa), ja que
    // o check e apenas decorativo. As opcoes formam um grupo mutuamente
    // exclusivo, comunicado via Semantics.
    return Semantics(
      inMutuallyExclusiveGroup: true,
      child: ListTile(
        selected: selected,
        title: Text(label),
        trailing: selected
            ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
            : null,
        onTap: onTap,
      ),
    );
  }
}
