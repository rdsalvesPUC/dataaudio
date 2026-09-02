# ADR-0004 — Persistência local: shared_preferences

**Status:** Aceito

**Contexto:** RF06 (baseline) exige persistência local. Os dados a guardar são listas de faixas (favoritos, ouvidas), preferências (tema, idioma) e a sessão — volume pequeno, natureza chave-valor.

**Decisão:** Usar **shared_preferences**, com os dados serializados em JSON, atrás de um `LocalStorageService`.

**Consequências:**
- (+) Simples, suficiente para o volume, trivial de mockar nos testes.
- (−) Inadequado para consultas relacionais ou grandes volumes — não é o nosso caso.

**Alternativas consideradas:** Hive (rápido e tipado, mas adiciona setup e, com type adapters, codegen); sqflite (relacional e poderoso, excessivo para dados chave-valor simples).


---
*[Índice de ADRs](README.md) · [SDD](../02-SDD.md) · [PRD](../01-PRD.md)*
