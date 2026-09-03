# ADR-0011 — Internacionalização e tema: flutter_localizations + intl + ThemeMode

**Status:** Aceito

**Contexto:** PF01/PF02 pedem tema claro/escuro e múltiplos idiomas, seguindo o sistema ou por escolha manual, com preferências persistidas (RN08). Retrofit dessas features é caro (risco no PRD).

**Decisão:** i18n via **flutter_localizations + intl** (arquivos ARB + gen-l10n), idiomas iniciais **PT-BR e Inglês** (extensível). Tema via `ThemeData` claro/escuro + `ThemeMode` dirigido pelo `SettingsProvider`. Ambos persistidos e **embutidos desde o primeiro commit**; nenhuma string ou cor chumbada.

**Consequências:**
- (+) 100% da UI traduzível; adicionar um idioma não toca nas telas.
- (+) Tema coerente e acessível (contraste nos dois modos, RF10).
- (−) Exige a disciplina de externalizar toda string desde o início — que é justamente a mitigação do risco de retrofit.

**Alternativas consideradas:** pacote de terceiros como `easy_localization` (desnecessário; o oficial resolve); strings/cores hardcoded (rejeitado: retrofit caro e quebra i18n/tema).


---
*[Índice de ADRs](README.md) · [SDD](../02-SDD.md) · [PRD](../01-PRD.md)*
