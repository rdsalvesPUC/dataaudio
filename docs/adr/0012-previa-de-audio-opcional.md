# ADR-0012 — Prévia de áudio de 30s (feature opcional)

**Status:** Proposto (opcional, entra após os RF obrigatórios)

**Contexto:** A Deezer fornece uma URL de prévia de 30s por faixa. Tocar essa prévia enriquece o tema música, mas **não** é exigido por nenhum RF. Por isso, só entra depois que RF01–RF10 e os testes estiverem sólidos.

**Decisão:** Se/quando implementada, usar `just_audio` (streaming de URL, maduro) ou `audioplayers` (mais simples). A escolha final fica **adiada** até a feature entrar em escopo. Tratar prévia ausente (`preview` vazio) sem quebrar a tela.

**Consequências:**
- (+) Deixa o app de música "vivo".
- (−) Dependência extra, tratamento de ausência e possíveis permissões — motivo de ficar por último.

**Alternativas consideradas:** não implementar áudio (a Tela de Detalhes funciona sem tocar) — este é o *fallback* padrão se o prazo apertar.


---
*[Índice de ADRs](README.md) · [SDD](../02-SDD.md) · [PRD](../01-PRD.md)*
