# ADR-0007 — Navegação: Navigator 1.0 com rotas nomeadas

**Status:** Aceito

**Contexto:** O fluxo é simples: login → home (abas) → detalhe. A rubrica cita `push`, `pop` e `replacement` como tema.

**Decisão:** Usar **Navigator 1.0** com rotas nomeadas (`/login`, `/home`, `/detail`) via `onGenerateRoute`. Login e logout usam `pushReplacement` (não há "voltar" ao estado de sessão anterior); o detalhe usa `push`/`pop`.

**Consequências:**
- (+) Simples e suficiente; cobre diretamente o tema de navegação do vídeo.
- (−) Menos poder para deep-linking e rotas declarativas — não necessário no escopo.

**Alternativas consideradas:** GoRouter / Navigator 2.0 (poderosos, mas complexidade desnecessária aqui).


---
*[Índice de ADRs](README.md) · [SDD](../02-SDD.md) · [PRD](../01-PRD.md)*
