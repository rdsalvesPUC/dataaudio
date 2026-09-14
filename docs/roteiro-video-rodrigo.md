# Roteiro de vídeo — Rodrigo Alves

**Parte:** RF06/RF07 (persistência local, login, Ouvidas) + bônus Firebase
**Duração alvo:** ~2 min

---

### 0:00 — Abertura (15s)
> "Eu fiquei com a **persistência e a sessão** — RF06 e RF07 — mais o **bônus de nuvem com Firebase**.
> A ideia central da minha parte é uma só: **as telas nunca sabem se os dados vêm do celular ou da nuvem.**"

*Tela: `lib/repositories/` aberto, mostrando os pares `local_*` e `cloud_*` / `firebase_*`.*

---

### 0:15 — RF06: persistência local (25s)
> "Favoritos e Ouvidas são gravados via `LocalStorageService`, sobre `shared_preferences`.
> A gente serializa a **`Track` inteira** em JSON, não só o id — então a lista funciona **offline**, sem precisar rebater na API da Deezer."

*Tela: `local_listened_repository.dart` → método `add`/`getAll`.*

---

### 0:40 — RF07: login que sobrevive ao restart (30s)
> "O login local está no `LocalAuthRepository`. Detalhe de segurança: a **senha nunca é gravada crua** — guardo um `salt` aleatório por usuário e o **SHA-256 de salt + senha**."

*Tela: `local_auth_repository.dart` linhas do `_hash` e `_newSalt`.*

> "A sessão fica persistida, então o `AuthProvider.restoreSession` **recupera o login ao abrir o app**. E ele governa a regra RN01: **sem sessão, não há catálogo** — a navegação é condicional."

*Tela: `auth_provider.dart` → `restoreSession` e `isAuthenticated`.*

---

### 1:10 — Ouvidas com feedback instantâneo (20s)
> "As Ouvidas ficam no `ListenedProvider`: a lista vive em memória pra UI reagir na hora, e a persistência é delegada ao repositório. O `toggle` é **otimista** — reflete na hora e, se a gravação falhar, **reverte** pra manter memória e disco consistentes."

*Tela: `listened_provider.dart` → `toggle`.*

---

### 1:30 — Bônus Firebase: a troca sem tocar nas telas (25s)
> "No bônus, a **mesma interface** ganha uma implementação de nuvem: `FirebaseAuthRepository` (Auth por e-mail/senha) e `FirestoreService`, que guarda as listas em `users/{uid}/...` — **isoladas por usuário**."

*Tela: `firestore_service.dart` → `_collection` com o `uid`.*

> "E o pulo do gato: **tudo isso é escolhido num único ponto**, o composition root, por uma flag `useCloud`. Trocar de local pra nuvem **não altera uma linha de tela** — é o repository pattern das nossas ADRs valendo na prática."

*Tela: `composition_root.dart` linhas 65–73 (o `useCloud ? Cloud... : Local...`).*

---

### 1:55 — Fecho (10s)
> "Resumindo: persistência offline, login seguro e com sessão, Ouvidas reativas, e uma nuvem que entra e sai por uma flag. Passo pro/pra próximo(a)."

---

## Se o professor perguntar
- **"Por que hash e não a senha?"** → Nunca persistir senha em claro; `salt` por usuário evita rainbow tables. É baseline local; na nuvem quem cuida disso é o Firebase Auth.
- **"Como troca local ↔ nuvem?"** → Flag `useCloud` no composition root (`--dart-define=USE_CLOUD=true`). As telas dependem só das interfaces (`AuthRepository`, `ListenedRepository`), então não mudam.
- **"E se a gravação/sessão falhar?"** → `restoreSession` descarta sessão corrompida e segue deslogado (não trava no spinner); `toggle` reverte a UI. Ambos cobertos por teste.
