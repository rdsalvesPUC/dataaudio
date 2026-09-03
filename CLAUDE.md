# CLAUDE.md — Contexto do projeto DataAudio

> Arquivo de contexto lido automaticamente pelo Claude Code. Mantém as decisões já tomadas na fase de design, para que nenhuma sessão precise redescobri-las.

## O que é

**DataAudio** — app Flutter de catálogo interativo de músicas consumindo a API pública da **Deezer**.
Trabalho somativo da disciplina Desenvolvimento Mobile Híbrido (BSI), Prof. Mark Joselli. Vale **20%** da nota final. **Entrega: 20/09/2026.** Grupo de até 4 pessoas.
Repositório: https://github.com/rdsalvesPUC/dataaudio (público, MIT).

A rubrica completa e os documentos de design estão em `docs/`. **Leia `docs/` antes de tomar qualquer decisão de arquitetura** — PRD, SDD, 14 ADRs e Plano de Testes já estão escritos e aprovados.

## ⚠️ PRIMEIRA TAREFA DE TODA SESSÃO INICIAL

**Antes de escrever qualquer código ou fazer scaffolding**, verificar o ambiente autonomamente (não perguntar ao usuário — usar as ferramentas):

```bash
flutter doctor -v
flutter --version
git --version
node --version        # necessário para o Firebase CLI
```

Checar: Flutter no canal estável, Android SDK, licenças aceitas, emulador disponível (`flutter emulators`), e se `firebase-tools`/`flutterfire_cli` estão instalados (só necessários para os bônus). **Reportar o que falta e resolver antes de prosseguir.**

## Decisões travadas (não reabrir sem motivo)

| Tema | Decisão | ADR |
|---|---|---|
| API | Deezer (endpoints públicos, **sem autenticação**, sem segredos no repo) | 0001 |
| Estado global | `provider` (ChangeNotifier) | 0002 |
| Leituras pontuais | `FutureBuilder` (detalhe e busca); Provider para o que é compartilhado | 0003 |
| Persistência local | `shared_preferences` + JSON | 0004 |
| Nuvem (bônus) | Firebase: Firestore + Firebase Auth | 0005 |
| Arquitetura | Camadas + repository pattern + MVVM; telas em **`views/`** | 0006 |
| Navegação | Navigator 1.0, rotas nomeadas; `pushReplacement` em login/logout | 0007 |
| Erros | Exceções tipadas → `failure_mapper` → mensagem **localizada** | 0008 |
| Testes | `mocktail`, `http.Client` injetado, **sem codegen** (`fromJson` à mão) | 0009 |
| Design system | **Material 3 + widgets `.adaptive`** (cross-platform consciente) | 0010 |
| Tema e i18n | `flutter_localizations` + `intl` (ARB); PT-BR e EN; `ThemeMode` | 0011 |
| Prévia de áudio | **Opcional**, só após RF01–RF10 e testes sólidos | 0012 |
| Validação visual | Golden tests cirúrgicos (views principais × tema × idioma) | 0013 |
| Git e CI | Trunk-based, branches `feature/rfXX-nome`; CI só com analyze + unit/widget | 0014 |

## Convenções obrigatórias

- **Nenhuma string chumbada na UI** — tudo via `AppLocalizations` (ARB), desde o primeiro commit.
- **Nenhuma cor chumbada** — só via `Theme.of(context)`.
- **Nada de I/O direto nas views/providers** — sempre através de interfaces de repositório.
- Implementações concretas escolhidas **só** no composition root (`lib/core/di/`).
- Favoritos e Ouvidas persistem a `Track` **inteira** serializada (funciona offline).
- `test/` espelha `lib/`; padrão Arrange-Act-Assert; goldens em `test/goldens/`.
- Commits em português, imperativo, referenciando o RF quando aplicável.

## Método de trabalho: TDD

Implementação segue **red → green → refactor**, guiada pelos critérios de aceite do PRD (§5).
Ordem, de dentro para fora: **models → services → repositories → providers → views.**
Cada camada nasce testada antes de a próxima depender dela.

**Meta de cobertura: ≥ 80%** de linhas na lógica (models, services, repositories, providers, core).
Excluídos do cálculo: `main.dart`, `app.dart`, `firebase_options.dart`, l10n gerado. Ver `docs/04-Plano-de-Testes.md` §6.

## Ordem de implementação

1. **Setup:** verificar ambiente → `flutter create` → estrutura de pastas → `pubspec` → `.gitignore` → `analysis_options` → CI.
2. **Obrigatórios (RF01–RF10)** — prioridade máxima, é onde está 90% da nota.
3. **Personalização (PF01 tema / PF02 i18n)** — infraestrutura desde o início; telas de ajuste quando as views existirem.
4. **Bônus Firebase** (RF06 nuvem → RF07 auth real) — só depois que o baseline estiver completo e testado.
5. **Prévia de áudio** — opcional, por último.

## Fronteira de responsabilidades

**O Claude Code faz:** todo o código, todos os testes, scaffolding, configuração, execução de comandos e testes locais, verificação de ambiente.
**O usuário faz:** criar o projeto no console do Firebase (exige login Google no navegador), `git push`, gravar o vídeo, montar o PDF de entrega.

Nunca commitar segredos. `firebase_options.dart` e `google-services.json` **não** são versionados.

## O que ainda falta preencher

- Nomes completos de **todos** os integrantes (README + capa do PDF). *Nome faltando na capa = nota ZERO para aquele integrante.*
- Screenshots das telas principais (README e PDF).
- Tabela de autoavaliação dos RF (README já tem o esqueleto).
