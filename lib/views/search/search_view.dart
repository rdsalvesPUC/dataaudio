import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/error/failure_mapper.dart';
import '../../core/navigation/app_routes.dart';
import '../../l10n/app_localizations.dart';
import '../../models/track.dart';
import '../../repositories/catalog_repository.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_indicator.dart';

/// RF08 — Busca. `TextField` + `TextEditingController` + botao "Buscar" chamam
/// o endpoint de busca (RF08); cada resultado navega ao detalhe (RF02). Termo
/// sem resultado mostra mensagem amigavel; carregando/erro seguem o RF09.
///
/// A busca e disparada por acao do usuario, entao o estado assincrono e
/// controlado explicitamente (loading/erro/resultado) com `try/catch`.
class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final _controller = TextEditingController();

  bool _searched = false;
  bool _loading = false;
  Object? _error;
  List<Track> _results = const [];

  /// Identifica a busca atual: respostas de buscas anteriores (obsoletas) sao
  /// descartadas quando uma nova e disparada (evita que uma resposta lenta
  /// sobrescreva o resultado de uma query mais recente).
  int _requestId = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;
    final repository = context.read<CatalogRepository>();
    final requestId = ++_requestId;
    setState(() {
      _searched = true;
      _loading = true;
      _error = null;
    });
    try {
      final page = await repository.search(query);
      if (!mounted || requestId != _requestId) return; // resposta obsoleta
      setState(() {
        _results = page.tracks;
        _loading = false;
      });
    } catch (e) {
      if (!mounted || requestId != _requestId) return; // resposta obsoleta
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.searchButton)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _run(),
                    decoration: InputDecoration(
                      hintText: l10n.searchHint,
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    _run();
                  },
                  child: Text(l10n.searchButton),
                ),
              ],
            ),
          ),
          Expanded(child: _buildBody(l10n)),
        ],
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (!_searched) return _centered(l10n.searchPrompt);
    if (_loading) return const LoadingIndicator();
    if (_error != null) {
      return ErrorView(message: mapFailure(l10n, _error), onRetry: _run);
    }
    if (_results.isEmpty) return _centered(l10n.errorNotFound);

    return ListView.separated(
      itemCount: _results.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final track = _results[index];
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
          // Sem maxLines: quebra em linhas com a fonte ampliada (RF10).
          title: Text(track.title),
          subtitle: Text(track.artistName),
          onTap: () => Navigator.of(context)
              .pushNamed(AppRoutes.detail, arguments: track),
        );
      },
    );
  }

  Widget _centered(String text) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      );
}
