import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../core/navigation/app_routes.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../catalog/catalog_view.dart';
import '../favorites/favorites_view.dart';
import '../listened/listened_view.dart';

/// Casca principal com navegacao por abas: catalogo / favoritos / ouvidas /
/// ajustes (SDD §7). Por ora so o catalogo (RF01) esta implementado; as demais
/// abas sao placeholders ate os respectivos RF.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final pages = <Widget>[
      const CatalogView(),
      const FavoritesView(),
      const ListenedView(),
      _Placeholder(label: l10n.navSettings),
    ];

    final titles = <String>[
      l10n.navCatalog,
      l10n.navFavorites,
      l10n.navListened,
      l10n.navSettings,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_index]),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: l10n.searchButton,
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.search),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: l10n.logout,
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed(AppRoutes.login);
              }
            },
          ),
        ],
      ),
      // IndexedStack mantem todas as abas vivas: trocar de aba nao descarta a
      // CatalogView (preserva paginas carregadas e posicao de scroll).
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.library_music_outlined),
            selectedIcon: const Icon(Icons.library_music),
            label: l10n.navCatalog,
          ),
          NavigationDestination(
            icon: const Icon(Icons.favorite_border),
            selectedIcon: const Icon(Icons.favorite),
            label: l10n.navFavorites,
          ),
          NavigationDestination(
            icon: const Icon(Icons.history_outlined),
            selectedIcon: const Icon(Icons.history),
            label: l10n.navListened,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.navSettings,
          ),
        ],
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(label, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}
