# ADR-0014 — Fluxo Git (trunk-based) e escopo do CI

**Status:** Aceito

**Contexto:** O projeto é desenvolvido por um grupo de até 4 pessoas, com **entrega única** em 20/09/2026 — não há múltiplas versões em produção nem releases paralelos. A rubrica exige que cada integrante implemente e explique uma parte (item 7), o que torna a rastreabilidade de autoria relevante. Git Flow, com `develop`, `release/*` e `hotfix/*`, foi desenhado para produtos com versionamento explícito e várias versões vivas simultaneamente; o próprio autor passou a recomendá-lo apenas nesse cenário.

**Decisão:**
1. **Trunk-based simplificado:** `main` protegida + branches curtas de feature, nomeadas pelo requisito — `feature/rf01-catalogo`, `feature/rf04-favoritos`, etc. Integração via pull request.
2. **CI em GitHub Actions** (`.github/workflows/ci.yml`), criado por nós, disparando em push e PR: `flutter analyze` + `flutter test --coverage` (unit e widget).
3. **Testes de integração e goldens ficam fora do CI**, executados localmente — integração antes de abrir PR.

**Consequências:**
- (+) Sem cerimônia desnecessária: nenhuma branch existe sem propósito no horizonte de uma entrega única.
- (+) Branches nomeadas por RF dão rastreabilidade dupla — o histórico mostra **o que** foi feito e **por quem**, evidenciando a contribuição de cada integrante.
- (+) O CI impede que código quebrado entre na `main`, protegendo a nota, e demonstra maturidade de engenharia no portfólio.
- (−) Testes de integração dependem de disciplina humana (rodar antes do PR), não de um gate automático.
- (−) Branches longas ou muitas simultâneas gerariam conflito; mitigado mantendo-as curtas e por RF.

**Alternativas consideradas:** Git Flow completo (rejeitada: `develop`/`release`/`hotfix` não resolvem nenhum problema real deste projeto); commits direto na `main` sem branches (defensável para autor único, mas perderia o isolamento entre integrantes e a evidência de contribuição individual); rodar integração no CI com emulador Android em runner (possível, porém lento e instável — reavaliar apenas se sobrar tempo, como job manual ou agendado).

---
*[Índice de ADRs](README.md) · [Plano de Testes](../04-Plano-de-Testes.md) · [PRD](../01-PRD.md)*
