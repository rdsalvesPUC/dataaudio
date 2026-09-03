# ADR-0006 — Arquitetura em camadas + repository pattern + views (MVVM)

**Status:** Aceito

**Contexto:** A rubrica premia a separação em `services/models/providers/screens`. Precisamos trocar as fontes de dados (local ↔ nuvem) sem reescrever a UI e queremos alta testabilidade.

**Decisão:** Organizar em camadas (`models`, `services`, `repositories`, `providers`, `views`, `core`, `widgets`). As telas ficam em **`views/`** num enquadramento **MVVM** (os Providers atuam como ViewModels). Toda dependência externa (Deezer, storage, Firebase) fica atrás de uma **interface de repositório**, cuja implementação concreta é escolhida no **composition root**.

**Consequências:**
- (+) Baseline e bônus intercambiáveis sem tocar em telas/providers.
- (+) Cada camada é testável isoladamente (viabiliza os 80%).
- (+) Separação clara, no espírito do que a rubrica valoriza.
- (−) Mais arquivos e indireção — desejável aqui, mas exige disciplina.
- (−) `views` diverge do termo literal "screens" da rubrica — mitigado: o README explicará o mapeamento (view = tela; provider = viewmodel).

**Alternativas consideradas:** acesso direto a Deezer/Firebase dentro das telas (rejeitado: acopla, impede teste e inviabiliza o swap do bônus); estrutura de pasta única (rejeitado: perde nota de organização).


---
*[Índice de ADRs](README.md) · [SDD](../02-SDD.md) · [PRD](../01-PRD.md)*
