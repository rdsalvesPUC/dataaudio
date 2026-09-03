# ADR-0013 — Validação visual: golden tests cirúrgicos

**Status:** Aceito

**Contexto:** Testes de widget verificam comportamento (o botão chamou o método? o loading apareceu?), mas não detectam **regressão visual**: uma mudança de tema que quebra o contraste de outra tela, ou uma tradução mais longa que estoura o layout. Com duas dimensões de variação — tema claro/escuro (PF01) e PT-BR/EN (PF02) —, o número de combinações visuais a conferir manualmente cresce rápido e é justamente onde erros passam despercebidos (RF10).

**Decisão:** Adotar **golden tests** (`matchesGoldenFile`) de forma **cirúrgica**: apenas nas views principais (`Catalog`, `TrackDetail`, `Favorites`, `Listened`, `Login`, `Settings`), cobrindo as combinações tema claro × escuro, PT-BR × EN e uma variante com `textScaler` ampliado. Imagens de referência versionadas em `test/goldens/`. Os goldens **rodam localmente** e ficam **fora do CI** (ver ADR-0014).

**Consequências:**
- (+) Regressão visual acidental é detectada automaticamente, com imagem de diff apontando o que mudou.
- (+) Cobre justamente o risco de i18n/tema registrado no PRD (texto estourando layout, contraste).
- (−) Goldens são frágeis: fontes renderizam de forma diferente entre sistemas operacionais, então uma referência gerada no Windows pode falhar num runner Linux — motivo de mantê-los fora do CI.
- (−) Exigem re-geração deliberada (`--update-goldens`) a cada mudança intencional de UI; por isso o escopo é limitado às views principais.
- (−) **Não** julgam se a interface faz sentido ou está bonita: apenas detectam que ela mudou em relação a uma referência aprovada por um humano. O julgamento estético segue humano.

**Alternativas consideradas:** nenhuma validação visual (rejeitada: regressões de tema/i18n passariam despercebidas); goldens em todos os widgets (rejeitada: manutenção desproporcional, quebras constantes); serviço externo de visual regression (fora de escopo para um trabalho acadêmico).

---
*[Índice de ADRs](README.md) · [Plano de Testes](../04-Plano-de-Testes.md) · [SDD](../02-SDD.md)*
