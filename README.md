# Newsify

A Flutter news reader built around clean architecture. Pulls live headlines from [NewsAPI](https://newsapi.org), supports category filtering, full-text search, and offline-saved favorites.

---

## What's inside

| Layer | Responsibility |
|---|---|
| **Presentation** | Screens, widgets, Riverpod providers (UI state only) |
| **Domain** | Entities, repository interfaces, use cases — zero Flutter imports |
| **Data** | Dio (remote), Hive (local), repository implementations, JSON models |

Dependencies only flow inward. Presentation knows about Domain. Data knows about Domain. Domain knows about nothing.

---

## Folder structure

```
lib/
├── core/
│   ├── constants/        # API base URL, category list, Hive box names
│   ├── errors/           # Sealed Failure class (Network, Server, Cache, NoInternet)
│   ├── network/          # Dio client + API key interceptor
│   ├── router/           # GoRouter config + auth redirect guard
│   └── theme/            # MaterialTheme, dark default, text styles
│
├── data/
│   ├── datasources/
│   │   ├── local/        # Hive: favorites box + auth box
│   │   └── remote/       # Dio calls → ArticleModel list
│   ├── models/           # ArticleModel with @HiveType + fromJson/toJson
│   └── repositories/     # Concrete impls, wrap calls in Either
│
├── domain/
│   ├── entities/         # Article, User — plain Dart, Equatable
│   ├── repositories/     # Abstract interfaces
│   └── usecases/         # One class per operation, single call() method
│
├── presentation/
│   ├── providers/        # AsyncNotifier (feed, auth, favorites), StateNotifier (search)
│   ├── screens/          # auth / feed / search / detail / favorites
│   └── widgets/          # ArticleCard, ShimmerList, AppErrorWidget, NoInternetBanner
│
└── main.dart             # Hive init, box registration, ProviderScope
```

---

## State management

Everything async runs through Riverpod. The pattern is the same across every feature:

- **`AsyncNotifierProvider`** — news feed (per category), favorites list, auth session
- **`StateNotifierProvider`** — search, with a 300ms `Timer` debounce so the API isn't hit on every keystroke
- **`StreamProvider`** — connectivity status via `connectivity_plus`
- All screens are `ConsumerWidget` or `ConsumerStatefulWidget`, calling `ref.watch` / `ref.read`

Error flow: repositories return `Either<Failure, T>`. Notifiers map `Left` to `AsyncValue.error`. Screens call `.when(data:, loading:, error:)` — no scattered null checks or try/catch in the widget tree.

---

## Key decisions

**Hive over SharedPreferences**
Articles are structured objects. A Hive `TypeAdapter` serializes them directly to binary — no manual JSON round-trips, and reads are synchronous so the favorites screen loads instantly.

**`dartz` Either**
Forces honest error handling at the call site. The domain layer never throws for expected failures; it returns a typed `Failure`. The UI layer can't accidentally ignore an error path.

**NewsAPI.org**
Two endpoints cover the whole app: `/top-headlines` for the category feed and `/everything` for search. The JSON shape (`articles[].title`, `urlToImage`, `publishedAt`) maps directly to the `Article` entity with no transformation gymnastics.

**GoRouter `ShellRoute`**
Bottom navigation tabs share one scaffold instance. Auth redirect lives in a single `redirect` callback — clean separation from screen code.


### Demo login

```
Email:     demo@newsapp.com
Password:  password123
```

Credentials are hardcoded in `AuthRepositoryImpl`. No backend required — the assignment scope is the Flutter architecture, not auth infrastructure.

---

## API reference

| Screen | Endpoint | Params |
|---|---|---|
| News Feed | `GET /v2/top-headlines` | `category`, `page`, `pageSize` |
| Search | `GET /v2/everything` | `q`, `page`, `pageSize` |

The Dio interceptor attaches `apiKey` to every request automatically.

---

## Notes

- NewsAPI free tier: 100 requests/day, `/everything` limited to articles from the past month. Fine for local dev and evaluation.
- Offline favorites work without any network — Hive reads are synchronous.
- Feed pagination loads 20 articles per page. Each category tab tracks its own page counter independently via Riverpod's `family` modifier.
- The app targets Flutter 3+ with full null safety. No deprecated APIs used.