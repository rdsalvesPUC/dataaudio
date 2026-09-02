# ADR-0003 — FutureBuilder para leituras de um disparo

**Status:** Aceito

**Contexto:** RF09 recomenda explicitamente `FutureBuilder`. A Tela de Detalhes e o resultado da Busca são leituras **pontuais** (um disparo, sem estado que evolui entre telas).

**Decisão:** Usar **FutureBuilder** na Tela de Detalhes e no resultado da Busca; usar Provider para o estado que persiste/muda entre telas (ADR-0002).

**Consequências:**
- (+) Loading, erro e dado tratados num único lugar, de forma declarativa.
- (+) Cumpre a recomendação da rubrica e demonstra a ferramenta.
- (−) Dois padrões coexistem no código — mitigado por uma fronteira clara e documentada (SDD 5.6).

**Alternativas consideradas:** `then/catchError` manual (mais verboso, mais sujeito a bugs de estado e `setState` após `dispose`); colocar tudo em Provider (funcionaria, mas perderia a demonstração de FutureBuilder que a rubrica pede).


---
*[Índice de ADRs](README.md) · [SDD](../02-SDD.md) · [PRD](../01-PRD.md)*
