# ADR-0015 — Busca (RF08): lista de resultados, não navegação direta ao detalhe

**Status:** Aceito

**Contexto:** A rubrica (RF08) pede que o botão "Buscar" acione o endpoint de busca "**navegando direto para a Tela de Detalhes do item encontrado**". O problema: uma busca por termo (ex.: "queen", "amor") retorna **dezenas de resultados** — não existe "o item encontrado" único. Ir direto a *um* detalhe exigiria escolher arbitrariamente um resultado (ex.: o primeiro), descartando todos os outros e tirando do usuário a decisão de qual faixa abrir. O endpoint `/search` da Deezer é, por natureza, **um-para-muitos**.

**Decisão:** A `SearchView` exibe a **lista dos resultados** da busca; tocar num resultado navega para o seu detalhe (reaproveitando a navegação do RF02). O intento funcional do RF08 é atendido — `TextField` + `TextEditingController` + botão "Buscar" acionam o endpoint de busca e levam ao detalhe do item —, respeitando que uma busca é inerentemente uma coleção de resultados. Termo sem resultado mostra mensagem amigável (RF09).

**Consequências:**
- (+) Fluxo utilizável e esperado pelo usuário — é o padrão de todo app de música/mídia (Spotify, Deezer, Apple Music).
- (+) Reaproveita a mesma rota de detalhe (RF02); sem código duplicado.
- (+) Preserva a escolha do usuário entre vários resultados relevantes.
- (−) Diverge da leitura **literal** da rubrica ("direto para o detalhe"). O grupo sustenta, na defesa e no vídeo, que a leitura literal é inaplicável a uma busca com múltiplos resultados; a intenção do requisito (buscar → endpoint → detalhe) está cumprida.

**Alternativas consideradas:** Navegar direto ao detalhe do **primeiro** resultado (rejeitada: escolha arbitrária, descarta os demais, UX ruim e confusa — o usuário digita "amor" e cai numa faixa aleatória). Um comportamento "estou com sorte" (rejeitada, mesmo motivo).

---
*[Índice de ADRs](README.md) · [PRD](../01-PRD.md) · [SDD](../02-SDD.md)*
