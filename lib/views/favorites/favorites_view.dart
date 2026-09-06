import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/navigation/app_routes.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/favorites_provider.dart';
import '../../widgets/app_network_image.dart';

/// Tela de Favoritos (RF05). Observa o [FavoritesProvider]: desfavoritar some
/// da lista na hora, sem recarregar. Tocar num item abre o detalhe (RF02).
class FavoritesView extends StatelessWidget {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final favorites = context.watch<FavoritesProvider>();

    if (favorites.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.favorite_border,
                  size: 48, color: Theme.of(context).colorScheme.outline),
              const SizedBox(height: 12),
              Text(
                l10n.favoritesEmpty,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      );
    }

    final tracks = favorites.favorites;
    return ListView.separated(
      itemCount: tracks.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final track = tracks[index];
        return ListTile(
          leading: SizedBox(
            width: 48,
            height: 48,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: AppNetworkImage(
                url: track.coverSmall,
                excludeSemantics: true, // o ListTile ja anuncia titulo/artista
              ),
            ),
          ),
          title: Text(track.title,
              maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(track.artistName,
              maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: l10n.favoriteRemove,
            onPressed: () =>
                context.read<FavoritesProvider>().toggle(track),
          ),
          onTap: () => Navigator.of(context)
              .pushNamed(AppRoutes.detail, arguments: track),
        );
      },
    );
  }
}
