# ADR-0009 — Estratégia de testes e mocking: mocktail + injeção, sem codegen

**Status:** Aceito

**Contexto:** A meta é cobertura ≥ 80% na lógica. Para testar sem rede nem disco reais, precisamos mockar o cliente HTTP e o storage. Detalhes completos no `04-Plano-de-Testes.md`.

**Decisão:** Usar `flutter_test` + **mocktail**. Injetar `http.Client` e o storage por construtor. Escrever `fromJson`/`toJson` **à mão** (sem `json_serializable`) para evitar codegen e manter o mapeamento explícito e 100% coberto.

**Consequências:**
- (+) Testes rápidos, sem `build_runner`; mocking simples.
- (+) Modelos transparentes — bom para explicar no vídeo.
- (−) `fromJson` manual gera mais linhas (mas todas cobríveis e legíveis).

**Alternativas consideradas:** mockito (exige codegen/`build_runner`); json_serializable (codegen; menos transparente didaticamente).


---
*[Índice de ADRs](README.md) · [SDD](../02-SDD.md) · [PRD](../01-PRD.md)*
