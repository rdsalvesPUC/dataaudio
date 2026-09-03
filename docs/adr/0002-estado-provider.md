# ADR-0002 — Gerenciamento de estado: Provider

**Status:** Aceito

**Contexto:** RF04 exige favoritos como **estado global**, reativo entre telas (RF05). Sessão, ouvidas, ajustes e a lista paginada do catálogo também são estado compartilhado. A rubrica lista `provider` como pacote obrigatório.

**Decisão:** Usar **Provider** (`ChangeNotifier`) para todo estado compartilhado e mutável entre telas.

**Consequências:**
- (+) Reatividade automática: desfavoritar atualiza a tela de Favoritos sem recarregar (RF05).
- (+) Alinhado ao pacote exigido pela rubrica.
- (−) Algum boilerplate (`notifyListeners`); menos estrutura que Bloc para apps grandes — aceitável neste escopo.

**Alternativas consideradas:** `setState` (rejeitada: estado local não é compartilhado entre telas — ver ADR-0003 para onde ele *não* basta); Bloc/Riverpod (fora do escopo e da rubrica); GetX (opinativo demais, mistura navegação/DI/estado).


---
*[Índice de ADRs](README.md) · [SDD](../02-SDD.md) · [PRD](../01-PRD.md)*
