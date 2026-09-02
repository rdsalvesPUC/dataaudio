# ADR-0010 — Design system: Material 3 + widgets adaptive

**Status:** Aceito

**Contexto:** A disciplina é sobre desenvolvimento cross-platform. Não conseguimos testar iOS (ambiente Windows/Android). Material puro parece menos nativo no iOS; Cupertino puro seria **intestável** no nosso ambiente e nenhum RF o exige.

**Decisão:** Usar **Material 3** como base e **widgets `.adaptive`** nos pontos que importam (`Switch.adaptive`, `CircularProgressIndicator.adaptive`, `showAdaptiveDialog`), que renderizam Cupertino no iOS e Material no Android. O `MaterialApp` já adota automaticamente física de rolagem e transições de página no estilo iOS.

**Consequências:**
- (+) Demonstra consciência cross-platform (objetivo da disciplina) e rende material de vídeo.
- (+) Testável no Android (os adaptive caem em Material); baixo risco.
- (−) O caminho de renderização iOS não é testado em device por nós — assumido e declarado abertamente.

**Alternativas consideradas:** Material puro (menos nativo no iOS); Cupertino puro ou UI dupla iOS/Android (intestável no nosso ambiente e fora do escopo dos RF).


---
*[Índice de ADRs](README.md) · [SDD](../02-SDD.md) · [PRD](../01-PRD.md)*
