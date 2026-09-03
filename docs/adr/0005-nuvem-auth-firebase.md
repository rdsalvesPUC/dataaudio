# ADR-0005 — Persistência em nuvem e autenticação (bônus): Firebase

**Status:** Aceito

**Contexto:** Os bônus pedem persistência em nuvem (RF06, +10%) e autenticação real (RF07, +10%, dependente do primeiro). Precisamos de backend gerenciado com autenticação e banco sincronizável, bem integrado ao Flutter.

**Decisão:** Usar **Firebase** — **Cloud Firestore** para sincronizar favoritos/ouvidas e **Firebase Auth** para login. Ambos atrás das mesmas interfaces de repositório do baseline (ADR-0006), acionados por uma flag no composition root.

**Consequências:**
- (+) Integração madura com Flutter (FlutterFire); auth e banco no mesmo ecossistema.
- (+) Baseline local permanece 100% funcional e independente — o bônus é um plugue.
- (−) Exige criar projeto no console e, para algumas funções, o plano Blaze; a configuração é trabalho manual do aluno.

**Alternativas consideradas:** Supabase (Postgres + auth, bom, mas menos aderente ao ecossistema Flutter do curso); API própria (muito mais esforço, fora do foco da disciplina).


---
*[Índice de ADRs](README.md) · [SDD](../02-SDD.md) · [PRD](../01-PRD.md)*
