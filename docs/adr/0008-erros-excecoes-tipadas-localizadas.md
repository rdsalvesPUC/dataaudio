# ADR-0008 — Tratamento de erros: exceções tipadas → mensagem localizada

**Status:** Aceito

**Contexto:** RF09 exige mensagem de erro amigável em falhas de comunicação. Com i18n (PF02), a mensagem precisa aparecer no idioma do usuário.

**Decisão:** Definir uma hierarquia `AppException` (`NetworkException`, `ApiException`, `NotFoundException`, `TimeoutException`, `AuthException`). Os services **lançam** exceções tipadas; a UI **captura** e usa um `failure_mapper` para converter em uma **chave de string localizada**, exibida via `ErrorView`.

**Consequências:**
- (+) Erros claros, consistentes e traduzidos; UI nunca trava nem mostra stack trace.
- (−) É preciso manter o mapa exceção → mensagem.

**Alternativas consideradas:** tipo `Result`/`Either` (elegante, mas adiciona dependência e curva; exceções bastam no escopo); tratar erro solto em cada tela (rejeitado: inconsistente e repetitivo).


---
*[Índice de ADRs](README.md) · [SDD](../02-SDD.md) · [PRD](../01-PRD.md)*
