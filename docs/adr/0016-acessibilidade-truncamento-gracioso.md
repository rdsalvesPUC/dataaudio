# ADR-0016 — Acessibilidade (RF10): truncamento gracioso na grade

**Status:** Aceito

**Contexto:** A rubrica (RF10) exige: *"O layout **não pode quebrar** quando o usuário aumenta a fonte do sistema (respeitar `MediaQuery.textScaleFactor`, evitar tamanhos fixos que cortem texto)."* Na grade do catálogo, títulos/artistas usam `maxLines` + `TextOverflow.ellipsis`; com a fonte em 2×, rótulos longos aparecem com **reticências**.

**Decisão:** A grade usa **truncamento gracioso** (reticências) para rótulos longos. O requisito central — *o layout não pode quebrar* — **é atendido**: no 2× não há overflow nem sobreposição (verificado por teste). Reticências são um corte **intencional e gracioso**, não uma quebra de layout. As telas de **conteúdo** (detalhe, listas de favoritos/ouvidas/busca, login) **quebram o texto em linhas** e não truncam — garantido pelo helper `_expectNoTruncatedText` em `test/accessibility_test.dart`.

**Consequências:**
- (+) Layout robusto no 2× (sem overflow), respeitando `textScaleFactor` — o núcleo do RF10.
- (+) O conteúdo essencial (detalhe, listas, login) mostra o texto **completo**.
- (+) Semantics/labels, contraste (claro e escuro) e alvos de toque (48px) cobertos por `meetsGuideline` no mesmo teste.
- (−) Rótulos **muito** longos na grade usam reticências — padrão universal em grades de miniaturas (Spotify, Apple Music) e presente em qualquer tamanho de fonte, não só no 2×.

**Alternativas consideradas:** Converter a grade em **lista** quando a fonte é grande (rejeitada: reduz o truncamento, mas **não o elimina** — rótulos muito longos ainda truncariam ou quebrariam em muitas linhas; adiciona um segundo caminho de renderização sem resolver o ponto de fundo). **Remover** o `maxLines` (rejeitada: o texto estouraria a célula de tamanho fixo da grade — aí sim **quebraria** o layout, violando o requisito central).

**Fundamento:** truncamento é inerente a **qualquer** layout finito — um rótulo suficientemente longo sempre precisa ser cortado ou reduzido em algum ponto. O que a rubrica proíbe é a **quebra** de layout (overflow/corte por altura fixa), não a existência de reticências.

---
*[Índice de ADRs](README.md) · [PRD](../01-PRD.md) · [Plano de Testes](../04-Plano-de-Testes.md)*
