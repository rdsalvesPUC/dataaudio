# ADR-0001 — API de dados: Deezer

**Status:** Aceito

**Contexto:** O projeto precisa de uma API pública e gratuita, no tema música, que ofereça lista paginada, busca e detalhe de item, com imagens. A API do Spotify exige token OAuth em toda chamada; para catálogo sem login do usuário, o *Client Credentials flow* exige um **client secret** que não pode ser guardado com segurança num app mobile — o que conflita com o critério "ausência de segredos no repositório". Além disso, restrições recentes da Spotify (novembro/2024 e fevereiro/2026) reduziram endpoints de descoberta e removeram prévias de áudio para apps novos.

**Decisão:** Usar a **Deezer**. Os endpoints públicos de catálogo (`/chart`, `/search`, `/track`, `/album`, `/artist`) respondem **sem autenticação** para leitura; retornam capa de álbum e URL de prévia de 30s; e suportam paginação por `index`/`limit`.

**Consequências:**
- (+) Nenhum segredo no repositório; nada de OAuth para o catálogo.
- (+) Prévia de áudio tocável e imagens ricas — encaixe direto nos RF.
- (−) Rate limit (~50 req / 5 s) a ser respeitado na paginação e busca.
- (−) Dados de usuário do Deezer exigiriam OAuth; não os usamos (login é nosso, via ADR-0005).

**Alternativas consideradas:** Spotify (rejeitada: OAuth + secret + restrições recentes); iTunes Search API (viável, mas sem um endpoint de "chart" tão direto para a lista inicial); APIs fora do tema música (PokéAPI, Rick and Morty) — descartadas por tema.


---
*[Índice de ADRs](README.md) · [SDD](../02-SDD.md) · [PRD](../01-PRD.md)*
