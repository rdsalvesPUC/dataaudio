import 'package:flutter/material.dart';

/// Indicador de carregamento padronizado (RF09). Usa `.adaptive` para respeitar
/// a plataforma (ADR-0010).
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: CircularProgressIndicator.adaptive(),
      ),
    );
  }
}
