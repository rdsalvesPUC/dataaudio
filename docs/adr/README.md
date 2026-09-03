# Registros de Decisão de Arquitetura (ADR)

Uma decisão por arquivo, numeradas sequencialmente (convenção Nygard / MADR).
Cada ADR segue o formato: Contexto → Decisão → Consequências → Alternativas.
A coluna "Tema de vídeo" indica qual ponto da Explicação Técnica (rubrica, item 7) o ADR alimenta.

| ADR | Decisão | Tema de vídeo |
|---|---|---|
| [0001](0001-api-de-dados-deezer.md) | API de dados: Deezer | Tratamento de falhas de rede / escolha de API |
| [0002](0002-estado-provider.md) | Estado: Provider | Provider vs. setState |
| [0003](0003-futurebuilder-leituras-pontuais.md) | FutureBuilder para leituras pontuais | FutureBuilder vs. then/catchError |
| [0004](0004-persistencia-local-shared-preferences.md) | Persistência local: shared_preferences | Escolha do mecanismo de persistência |
| [0005](0005-nuvem-auth-firebase.md) | Nuvem/auth: Firebase (bônus) | Local vs. Nuvem (trade-offs) |
| [0006](0006-camadas-repository-views-mvvm.md) | Camadas + repository + views (MVVM) | Organização do projeto |
| [0007](0007-navegacao-navigator-nomeado.md) | Navegação: Navigator 1.0 nomeado | Pilha de navegação |
| [0008](0008-erros-excecoes-tipadas-localizadas.md) | Erros: exceções tipadas → mensagem localizada | Tratamento de falhas de rede |
| [0009](0009-testes-mocktail-injecao.md) | Testes: mocktail + injeção, sem codegen | Qualidade / robustez |
| [0010](0010-design-system-material3-adaptive.md) | Design system: Material 3 + adaptive | Cross-platform |
| [0011](0011-i18n-e-tema.md) | i18n e tema: flutter_localizations + intl | Cross-platform / estado global |
| [0012](0012-previa-de-audio-opcional.md) | Prévia de áudio (opcional) | — |
| [0013](0013-golden-tests.md) | Validação visual: golden tests cirúrgicos | Qualidade de UI / acessibilidade |
| [0014](0014-fluxo-git-e-ci.md) | Fluxo Git (trunk-based) e escopo do CI | Organização do projeto |

> Referências: [`01-PRD.md`](../01-PRD.md) · [`02-SDD.md`](../02-SDD.md) · [`04-Plano-de-Testes.md`](../04-Plano-de-Testes.md)
