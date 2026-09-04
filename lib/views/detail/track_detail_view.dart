import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/error/failure_mapper.dart';
import '../../l10n/app_localizations.dart';
import '../../models/track.dart';
import '../../repositories/catalog_repository.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_indicator.dart';

/// Tela de detalhes de uma faixa (RF03). Recebe a [Track] tocada no catalogo
/// e carrega o detalhe completo com **FutureBuilder** (leitura pontual, ADR-0003)
/// via [CatalogRepository.trackDetail]. Enquanto carrega mostra loading; em
/// falha, uma mensagem amigavel com "tentar novamente" (RF09).
class TrackDetailView extends StatefulWidget {
  const TrackDetailView({super.key, required this.track});

  final Track track;

  @override
  State<TrackDetailView> createState() => _TrackDetailViewState();
}

class _TrackDetailViewState extends State<TrackDetailView> {
  late Future<Track> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Track> _load() =>
      context.read<CatalogRepository>().trackDetail(widget.track.id);

  void _reload() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(widget.track.title)),
      body: FutureBuilder<Track>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator();
          }
          if (snapshot.hasError) {
            return ErrorView(
              message: mapFailure(l10n, snapshot.error),
              onRetry: _reload,
            );
          }
          // Fallback para a faixa recebida caso o detalhe venha vazio.
          return _DetailBody(track: snapshot.data ?? widget.track);
        },
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.track});

  final Track track;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final text = Theme.of(context).textTheme;
    final cover = track.coverBig.isNotEmpty ? track.coverBig : track.coverSmall;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: AppNetworkImage(url: cover, semanticLabel: track.title),
                ),
              ),
              const SizedBox(height: 20),
              Text(track.title, style: text.headlineSmall, textAlign: TextAlign.center),
              const SizedBox(height: 6),
              Text(
                track.artistName,
                style: text.titleMedium
                    ?.copyWith(color: Theme.of(context).colorScheme.primary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              if (track.albumTitle.isNotEmpty)
                _InfoRow(
                  icon: Icons.album_outlined,
                  label: l10n.detailAlbum,
                  value: track.albumTitle,
                ),
              if (track.durationSeconds > 0)
                _InfoRow(
                  icon: Icons.schedule_outlined,
                  label: l10n.detailDuration,
                  value: _formatDuration(track.durationSeconds),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: muted),
          const SizedBox(width: 12),
          Text(label, style: text.bodyMedium?.copyWith(color: muted)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, style: text.bodyLarge),
          ),
        ],
      ),
    );
  }
}

/// Formata segundos como m:ss (ex.: 224 -> "3:44").
String _formatDuration(int seconds) {
  final minutes = seconds ~/ 60;
  final rest = (seconds % 60).toString().padLeft(2, '0');
  return '$minutes:$rest';
}
