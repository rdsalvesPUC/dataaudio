import 'package:flutter/material.dart';

/// Imagem de rede com placeholder e rotulo de acessibilidade (RF01/RF03/RF10).
/// Centraliza o tratamento de capa ausente: URL vazia ou erro de carregamento
/// nunca quebram o layout (RN06).
///
/// Use [excludeSemantics] quando a capa fica ao lado de um texto que ja
/// descreve a faixa (grade, listas): a imagem vira decorativa e o leitor de
/// tela nao repete o titulo (RF10).
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.semanticLabel,
    this.fit = BoxFit.cover,
    this.excludeSemantics = false,
  });

  final String url;
  final String? semanticLabel;
  final BoxFit fit;
  final bool excludeSemantics;

  @override
  Widget build(BuildContext context) {
    final image = _buildImage();
    return excludeSemantics ? ExcludeSemantics(child: image) : image;
  }

  Widget _buildImage() {
    final placeholder = _Placeholder(semanticLabel: semanticLabel);
    if (url.isEmpty) return placeholder;

    return Image.network(
      url,
      fit: fit,
      semanticLabel: semanticLabel,
      errorBuilder: (_, _, _) => placeholder,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const _Placeholder();
      },
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({this.semanticLabel});

  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: semanticLabel,
      image: true,
      child: Container(
        color: scheme.surfaceContainerHighest,
        child: Icon(Icons.music_note, color: scheme.onSurfaceVariant),
      ),
    );
  }
}
