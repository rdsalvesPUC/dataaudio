import 'package:flutter/material.dart';

import '../models/track.dart';
import 'app_network_image.dart';

/// Item da grade do catalogo (RF01): capa + titulo + artista.
///
/// Acessibilidade (RF10): o item e anunciado como um alvo unico "titulo,
/// artista" (botao), sem repetir o titulo — a capa e decorativa.
class TrackGridItem extends StatelessWidget {
  const TrackGridItem({super.key, required this.track, this.onTap});

  final Track track;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Semantics(
          button: true,
          label: '${track.title}, ${track.artistName}',
          excludeSemantics: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: AppNetworkImage(
                  url: track.coverSmall,
                  excludeSemantics: true,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall,
                    ),
                    Text(
                      track.artistName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
