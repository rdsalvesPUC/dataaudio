# PRD — Documento de Requisitos de Produto

**Projeto:** DataAudio — Catálogo Interativo de Músicas
**Disciplina:** Desenvolvimento Mobile Híbrido (BSI) — Prof. Mark Joselli
**Versão do documento:** 1.1
**Status:** Em revisão
**Data de entrega do trabalho:** 20/09/2026

> Documento vivo. **Changelog:** v1.1 — nome definido como "DataAudio"; adicionados suporte a tema claro/escuro e internacionalização (i18n).

---

## 1. Resumo executivo

DataAudio é um aplicativo mobile (Flutter) de catálogo interativo de músicas que consome a API pública e gratuita da **Deezer**. O usuário faz login, navega por uma lista paginada de faixas, busca faixas específicas, vê detalhes (com capa, artista, álbum e prévia de 30s), marca faixas como **Favoritas** e como **Ouvidas**, e reencontra essas listas mesmo após fechar o app. O app se adapta ao usuário: **tema claro/escuro** (seguindo o sistema ou por escolha manual) e **múltiplos idiomas** (seguindo o idioma do sistema ou por escolha manual), com essas preferências preservadas entre sessões.

O produto existe para cumprir o Projeto Somativo da disciplina (20% da nota final) e para servir de peça de portfólio que demonstre competência nas áreas centrais do Flutter: widgets e layout, navegação, consumo assíncrono de API, gerenciamento de estado com Provider, persistência de dados e autenticação.

## 2. Contexto e motivação

O trabalho exige um app de catálogo que integre, num único produto coeso, todos os conceitos vistos em aula (RF01–RF10). O tema é livre; escolhemos **música via Deezer** porque a API oferece catálogo público sem autenticação (listagem, busca e detalhe), retorna capa de álbum e URL de prévia de 30 segundos, e suporta paginação — encaixando-se diretamente em cada requisito sem os obstáculos de credenciais que outras APIs de música impõem.

## 3. Objetivos e não-objetivos

### 3.1 Objetivos
- Entregar os dez requisitos funcionais obrigatórios (RF01–RF10) com qualidade de código e de interface.
- Alcançar os dois bônus (persistência em nuvem e autenticação real) via Firebase.
- Manter o repositório limpo, sem segredos expostos, com separação clara em camadas.
- Sustentar a arquitetura por uma suíte de testes (pirâmide completa) com cobertura ≥ 80% na lógica.

### 3.2 Não-objetivos (fora de escopo)
- Não é um serviço de streaming: **não** reproduz faixas completas — no máximo a prévia de 30s fornecida pela própria Deezer.
- Não implementa player avançado (fila, equalizador, letras sincronizadas, download offline de áudio).
- Não implementa rede social, comentários, seguir usuários ou compartilhamento.
- Não cobre iOS como alvo de entrega (foco Android/emulador); o código é multiplataforma, mas os testes de aceite ocorrem em Android.

## 4. Stakeholders e usuários

| Ator | Interesse |
|---|---|
| Integrantes do grupo | Autores; cada um implementa e explica ao menos uma parte (vídeo). |
| Professor / avaliador | Stakeholder de aceite; valida RF01–RF10, código, UI e o vídeo pela rubrica. |
| Usuário final (persona) | Pessoa que quer explorar músicas, ouvir prévias e guardar favoritas/ouvidas. |

**Persona principal — "Explorador de músicas":** abre o app, quer ver faixas populares de imediato, buscar uma faixa que lembrou, ouvir um trechinho e guardar o que gostou para depois. Valoriza rapidez, imagens e não perder suas listas.

## 5. Requisitos funcionais (visão de produto)

Reafirmação dos RF da rubrica, adaptados ao tema de faixas. O detalhamento técnico virá no SDD; aqui está o comportamento esperado e o **critério de aceite** de cada um.

| RF | Funcionalidade | Comportamento esperado | Critério de aceite |
|---|---|---|---|
| **RF01** | Catálogo + paginação | Após login, carrega faixas em `GridView` (capa + título/artista). Botão "Carregar Mais" anexa a próxima página. | Grade renderiza ≥ 1 página; "Carregar Mais" acrescenta itens sem recarregar a lista; faixa sem capa mostra placeholder e não quebra o layout. |
| **RF02** | Navegação p/ detalhes | Tocar numa faixa abre a Tela de Detalhes via `Navigator`. | Toque leva à tela correta com o item selecionado. |
| **RF03** | Detalhes da faixa | Exibe capa maior, título, artista, álbum e (se houver) prévia de 30s. | Todos os campos disponíveis aparecem; ausência de campo não quebra a tela. |
| **RF04** | Favoritar (Provider) | Botão de coração favorita/desfavorita; estado global via `provider`. | Favoritar reflete imediatamente em todas as telas que observam o estado. |
| **RF05** | Tela de Favoritos | Lista as faixas favoritadas; atualiza sozinha ao desfavoritar. | Remover favorito some da lista sem recarregar manualmente. |
| **RF06** | Persistência | Favoritos e Ouvidas sobrevivem a reinícios. Baseline: `shared_preferences`. | Fechar e reabrir o app preserva ambas as listas. |
| **RF07** | Login + Ouvidas | Exige login antes do catálogo; permite marcar faixa como "Ouvida"; tela/aba própria para vê-las. Baseline: login local. | Sem login não há acesso ao catálogo; marcar "Ouvida" reflete na tela de Ouvidas e persiste. |
| **RF08** | Busca | `TextField` + `TextEditingController` + botão "Buscar" chamam o endpoint de busca e levam ao detalhe do item encontrado. | Buscar um termo válido navega ao detalhe; termo sem resultado mostra mensagem amigável. |
| **RF09** | Feedback de UI | `CircularProgressIndicator` durante requisições; mensagem amigável em falha. `FutureBuilder` recomendado. | Toda operação assíncrona mostra carregando; falha de rede mostra erro legível, sem travar. |
| **RF10** | Acessibilidade | `Semantics`/`semanticLabel` em imagens e controles; contraste adequado **nos temas claro e escuro**; respeitar `textScaleFactor`; áreas de toque adequadas; layouts que não assumem o comprimento do texto (importante com i18n). | Leitor de tela anuncia os elementos; aumentar a fonte do sistema não corta texto; contraste ok em ambos os temas; alvos de toque confortáveis. |

### 5.1 Personalização — Tema e Idioma (extra ao escopo obrigatório)

Não são RF exigidos pela rubrica, mas são recursos de produto que decidimos incluir. São tratados como **fundação**: a infraestrutura é embutida desde o início (não retrofitada).

| ID | Funcionalidade | Comportamento esperado | Critério de aceite |
|---|---|---|---|
| **PF01** | Tema claro/escuro | O app oferece tema claro, escuro e "seguir o sistema". Padrão: seguir o sistema. A escolha do usuário persiste. | Alternar o tema muda a UI na hora; reabrir o app mantém a escolha; ambos os temas têm contraste adequado (RF10). |
| **PF02** | Internacionalização (i18n) | Toda a UI é traduzível; o idioma segue o sistema por padrão, com opção de troca manual. Idiomas iniciais: **PT-BR** e **Inglês** (extensível). A escolha persiste. | Nenhuma string chumbada na UI; trocar idioma reflete em todas as telas; reabrir mantém a escolha; layout não quebra com textos de tamanhos diferentes. |

Ambas as preferências são geridas por um `SettingsProvider` (via Provider) e persistidas junto das demais (RF06).

## 6. Requisitos não-funcionais (RNF)

| RNF | Descrição | Meta |
|---|---|---|
| Acessibilidade | Ver RF10 — é obrigatório e vale nota. | Telas principais navegáveis por leitor de tela. |
| Confiabilidade | Falha de rede nunca derruba o app; sempre há caminho de recuperação. | 0 crashes em falha de API simulada. |
| Desempenho | Rolagem fluida na grade; imagens com cache; paginação sob demanda. | Sem travamentos perceptíveis ao rolar/paginar. |
| Segurança | Nenhum segredo (chaves, config Firebase sensível) versionado. | `.gitignore` cobre `firebase_options.dart`/`google-services.json` conforme necessário. |
| Testabilidade | Lógica desacoplada de I/O (HTTP e storage injetáveis/mockáveis). | Cobertura ≥ 80% na lógica (services/providers/models/repos). |
| Offline parcial | Listas persistidas legíveis sem rede; catálogo exige rede. | Favoritos/Ouvidas visíveis offline. |
| Portabilidade | Código idiomático Flutter/Dart, multiplataforma. | Compila e roda em Android. |
| Tematização | Temas claro/escuro via `ThemeData`/`ThemeMode`, definidos desde o início. | Nenhuma cor chumbada nas telas; ambos os temas legíveis. |
| Internacionalização | Strings externalizadas (`flutter_localizations` + `intl`/ARB) desde o início; `Locale` segue o sistema ou override. | 100% da UI traduzível; adicionar um idioma não exige mexer nas telas. |

## 7. Regras de negócio

- **RN01** — O catálogo só é acessível após autenticação (local no baseline; real no bônus).
- **RN02** — Favoritar e marcar como Ouvida exigem sessão ativa.
- **RN03** — Uma faixa pode estar simultaneamente em Favoritos e em Ouvidas; são listas independentes.
- **RN04** — Favoritos e Ouvidas persistem entre sessões e reinícios.
- **RN05** — O catálogo é paginado; "Carregar Mais" nunca substitui a lista, sempre a estende.
- **RN06** — Item sem imagem usa placeholder; nunca quebra a UI.
- **RN07** *(bônus)* — Com autenticação real, Favoritos e Ouvidas ficam vinculadas ao usuário e sincronizadas na nuvem.
- **RN08** — As preferências de tema e idioma persistem entre sessões; na ausência de escolha do usuário, o app segue o tema e o idioma do sistema.

## 8. Fluxos principais

1. **Onboarding/Login:** abrir → tela de login → (cadastrar/entrar) → catálogo.
2. **Explorar catálogo:** catálogo (grade paginada) → "Carregar Mais" → rolar.
3. **Ver detalhe:** tocar na faixa → detalhe (capa, artista, álbum, prévia) → favoritar / marcar Ouvida.
4. **Buscar:** campo de busca → digitar → "Buscar" → detalhe do resultado.
5. **Minhas listas:** a partir do catálogo → Favoritos / Ouvidas → desfavoritar atualiza na hora.
6. **Persistência:** fechar app → reabrir → listas intactas (e sincronizadas, no bônus).

## 9. Escopo dos bônus (Firebase)

| Bônus | Descrição | Depende de |
|---|---|---|
| **RF06 nuvem (+10%)** | Sincronizar Favoritos e Ouvidas no **Cloud Firestore**. | Projeto Firebase configurado. |
| **RF07 auth real (+10%)** | **Firebase Auth** como login, com as listas vinculadas ao usuário autenticado. | Bônus de nuvem (RF06). |

Premissa de arquitetura: o baseline (local) e o bônus (nuvem) convivem atrás da **mesma interface de repositório**, permitindo trocar a implementação sem reescrever telas/providers. Isso protege a nota mesmo que o bônus seja cortado por tempo.

## 10. Feature secundária (opcional, não obrigatória)

- **Prévia de áudio de 30s** na Tela de Detalhes (usando a `preview` URL da Deezer). Enriquece o tema de música, mas **não** é exigida por nenhum RF. Prioridade baixa: só entra depois que RF01–RF10 e os testes estiverem sólidos, para não arriscar prazo. Decisão de pacote de áudio fica registrada em ADR.

## 11. Restrições e premissas

- **Stack:** Flutter + Dart. Pacotes obrigatórios: `http`, `provider`, `shared_preferences`. Personalização: `flutter_localizations` (SDK) + `intl` (i18n) e o suporte nativo de temas do Flutter. Bônus: `firebase_core`, `cloud_firestore`, `firebase_auth`.
- **API:** Deezer, endpoints públicos (`/chart`, `/search`, `/track`, `/album`, `/artist`) — sem autenticação para leitura de catálogo.
- **Rate limit da Deezer:** ~50 requisições / 5 s; a paginação e a busca devem respeitar isso.
- **Grupo:** até 4 pessoas; cada integrante implementa e explica ao menos uma parte.
- **Entrega:** PDF único no sistema da universidade + repositório GitHub público + vídeo YouTube (6–9 min).
- **Ambiente de execução:** build, emulador, testes e integração com Deezer/Firebase rodam na máquina local (fase Claude Code), não na sessão de Chat.

## 12. Critérios de sucesso (mapeados à rubrica)

| Bloco | Peso | Como garantimos |
|---|---|---|
| RF01 Catálogo/Paginação | 15% | GridView + "Carregar Mais" + placeholder, com testes. |
| RF02/03 Navegação/Detalhes | 10% | Navigator + tela de detalhe completa, com testes. |
| RF04/05 Favoritos (Provider) | 15% | Provider global + tela reativa, com testes. |
| RF06 Persistência local | 10% | shared_preferences atrás de repositório, com testes. |
| RF07 Login + Ouvidas | 10% | Login local + gestão de sessão + tela de Ouvidas. |
| RF08 Busca | 10% | TextField/Controller + endpoint de busca. |
| RF09 Feedback de UI | 10% | CircularProgressIndicator + tratamento de erro. |
| RF10 Acessibilidade | 10% | Semantics, contraste, textScaleFactor, alvos de toque. |
| Qualidade de código | 5% | Camadas (models/services/repositories/providers/screens), sem segredos. |
| Qualidade de UI/UX | 5% | Layout limpo e intuitivo. |
| Bônus nuvem + auth | +20% | Firestore + Firebase Auth atrás das interfaces de repositório. |

## 13. Riscos e mitigações

| Risco | Impacto | Mitigação |
|---|---|---|
| Rate limit / instabilidade da Deezer | Falhas em paginação/busca | Tratamento de erro (RF09), paginação sob demanda, mensagens amigáveis. |
| Prévia de áudio inconsistente entre faixas | Feature secundária falha | É opcional; tela de detalhe funciona sem áudio; tratar `preview` ausente. |
| Configuração do Firebase (console/CLI) consome tempo | Bônus em risco | Baseline local 100% funcional e independente; bônus atrás de interface trocável. |
| Prazo (20/09/2026) | Perda de nota por atraso | Ordem de entrega prioriza obrigatórios; bônus por último. |
| Segredo versionado sem querer | -nota (qualidade) e segurança | `.gitignore` desde o commit inicial; revisão antes de tornar o repo público. |
| Retrofit de i18n/tema (strings/cores chumbadas) | Retrabalho caro em todas as telas | Infra embutida desde o 1º commit; toda string nova já nasce externalizada; cores só via `ThemeData`. |

## 14. Definição de pronto (Definition of Done)

Uma funcionalidade está "pronta" quando: atende ao critério de aceite do RF; tem testes cobrindo o caminho feliz e ao menos um caminho de erro; passa no `flutter analyze` sem avisos relevantes; e está integrada à navegação sem quebrar as demais telas.

---

### Próximos documentos
- **SDD** — arquitetura em camadas, modelo de dados (local + Firestore), fluxo de navegação, contratos entre camadas.
- **ADRs** — registros de decisão (Deezer×Spotify, Provider×setState, shared_preferences×alternativas, Firebase, estrutura de pastas, estratégia de mocking, pacote de áudio, abordagem de tema & i18n).
- **Plano de Testes** — pirâmide (unit/widget/integração), metas de cobertura e ferramentas.
