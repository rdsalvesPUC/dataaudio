import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/error/failure_mapper.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/catalog_provider.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/track_grid_item.dart';

/// Tela do catalogo (RF01): grade paginada de faixas + "Carregar mais".
class CatalogView extends StatefulWidget {
  const CatalogView({super.key});

  @override
  State<CatalogView> createState() => _CatalogViewState();
}

class _CatalogViewState extends State<CatalogView> {
  @override
  void initState() {
    super.initState();
    // Carrega a primeira pagina apos o primeiro frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CatalogProvider>().loadInitial();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final catalog = context.watch<CatalogProvider>();

    if (catalog.isLoading && catalog.isEmpty) {
      return const LoadingIndicator();
    }

    if (catalog.error != null && catalog.isEmpty) {
      return ErrorView(
        message: mapFailure(l10n, catalog.error),
        onRetry: catalog.loadInitial,
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        childAspectRatio: 0.72,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: catalog.tracks.length + (catalog.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= catalog.tracks.length) {
          return _LoadMoreTile(
            isLoading: catalog.isLoadingMore,
            label: l10n.loadMore,
            onPressed: catalog.loadMore,
          );
        }
        return TrackGridItem(track: catalog.tracks[index]);
      },
    );
  }
}

class _LoadMoreTile extends StatelessWidget {
  const _LoadMoreTile({
    required this.isLoading,
    required this.label,
    required this.onPressed,
  });

  final bool isLoading;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: isLoading
          ? const LoadingIndicator()
          : FilledButton.tonal(onPressed: onPressed, child: Text(label)),
    );
  }
}
