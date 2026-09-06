import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/navigation/app_routes.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/listened_provider.dart';
import '../../widgets/app_network_image.dart';

/// Tela de Ouvidas (RF07). Observa o [ListenedProvider]: desmarcar remove da
/// lista na hora. Tocar num item abre o detalhe (RF02).
class ListenedView extends StatelessWidget {
  const ListenedView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final listened = context.watch<ListenedProvider>();

    if (listened.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.history,
                  size: 48, color: Theme.of(context).colorScheme.outline),
              const SizedBox(height: 12),
              Text(
                l10n.listenedEmpty,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      );
    }

    final tracks = listened.listened;
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
          title:
              Text(track.title, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(track.artistName,
              maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: IconButton(
            icon: const Icon(Icons.check_circle),
            tooltip: l10n.listenedUnmark,
            onPressed: () => context.read<ListenedProvider>().toggle(track),
          ),
          onTap: () => Navigator.of(context)
              .pushNamed(AppRoutes.detail, arguments: track),
        );
      },
    );
  }
}
