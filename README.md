# 🎬 Secret Vault — Hidden Movie & TV App

A production-quality Flutter mobile app that disguises itself as a simple calculator. Enter the correct secret code and unlock a fully-featured Movie & TV Series browser powered by the **TMDB API**.

---

## ✨ Features

### 🔢 Calculator Screen (Entry Point)
- Looks and behaves like a standard calculator
- Number buttons 0–9, operators, clear, backspace, equals
- Validates a configurable secret code on `=` press
- Wrong code shows "Invalid code" — correct code unlocks the hidden app
- Secret code is never displayed in the UI

### 🎥 Hidden Movie & TV App
- **Movies** — Popular, Top Rated, Now Playing, Upcoming, Trending, by Genre
- **TV Series** — Popular, Top Rated, Airing Today, On The Air, Trending, by Genre
- **Search** — Multi-search movies & TV series with debounce (500ms)
- **Favorites** — Save/remove locally with Hive (persists after app restart, works offline)
- **Trailers** — Play official trailers via YouTube (url_launcher)
- **Detail Pages** — Full metadata: poster, backdrop, rating, overview, genres, runtime, seasons, episodes

---

## 🏗️ Architecture

This project follows **Clean Architecture** with clear separation of concerns:

```
lib/
├── main.dart                    # App entry point, Hive init, Riverpod scope
├── app.dart                     # MaterialApp with GoRouter and dark theme
├── config/
│   └── env.dart                 # TMDB API key and secret code config
├── core/
│   ├── constants/               # App-wide constants
│   ├── errors/                  # Failures and exceptions
│   ├── network/                 # Dio client setup
│   ├── routing/                 # GoRouter configuration
│   ├── theme/                   # Dark theme
│   └── utils/                   # Shared utilities
├── features/
│   ├── calculator/
│   │   ├── domain/              # CalculatorLogic (pure, testable)
│   │   └── presentation/        # CalculatorPage (StatefulWidget)
│   ├── movies/
│   │   ├── data/                # MovieModel, MovieRemoteDatasource, MovieRepositoryImpl
│   │   ├── domain/              # Movie entity, MovieRepository interface
│   │   └── presentation/        # Riverpod providers, MoviesPage, MovieDetailPage, MovieListPage
│   ├── tv_series/
│   │   ├── data/                # TvSeriesModel, TvRemoteDatasource, TvRepositoryImpl
│   │   ├── domain/              # TvSeries entity, TvRepository interface
│   │   └── presentation/        # Riverpod providers, TvSeriesPage, TvSeriesDetailPage, TvListPage
│   ├── search/
│   │   └── presentation/        # SearchProvider, SearchPage
│   ├── favorites/
│   │   ├── data/                # FavoriteItemModel (Hive HiveObject)
│   │   └── presentation/        # FavoritesProvider (Hive-backed), FavoritesPage
│   └── video/
│       ├── domain/              # VideoItem entity
│       └── presentation/        # PlayButton widget
└── shared/
    ├── models/                  # Genre model
    └── widgets/                 # Reusable: PosterImage, RatingBadge, ErrorView, MainShell
```

### State Management: **Riverpod**
Chosen over Bloc and Provider because:
- First-class support for `AsyncValue` (loading/error/data states without boilerplate)
- `FutureProvider` / `StateNotifierProvider` are ideal for API + local state
- Zero `BuildContext` required for reading providers
- Better testability and compile-time safety than Provider

### HTTP Client: **Dio**
Chosen over `http` because:
- Built-in interceptors for auth headers and logging
- Automatic request timeout config
- Better error handling and `DioException` typing

### Local Storage: **Hive**
Chosen over Isar, SQLite, and SharedPreferences because:
- Extremely fast NoSQL key-value store
- First-class Flutter support with `hive_flutter`
- `HiveObject` typed adapters (generated with `build_runner`)
- Simple box API — perfect for a favorites list

---

## 🚀 Setup

### Prerequisites
- Flutter SDK ≥ 3.x (stable channel)
- Android Studio or Xcode (for device/emulator)
- A free TMDB account and API key

### 1. Get a TMDB API Key

1. Go to [https://www.themoviedb.org/](https://www.themoviedb.org/)
2. Create a free account
3. Navigate to **Settings → API**
4. Request a **Developer** API key (free)
5. Copy your **API Key (v3 auth)**

### 2. Configure the API Key

Open `lib/config/env.dart`:

```dart
class Env {
  // ── TMDB API key ────────────────────────────────────────────────────────────
  // Replace the empty string below with your TMDB v3 API key.
  // Get yours free at: https://www.themoviedb.org/settings/api
  static const String tmdbApiKey = 'YOUR_TMDB_API_KEY_HERE';

  // ── Secret calculator code ──────────────────────────────────────────────────
  // Change this to your preferred unlock code.
  // Do NOT commit a real secret to a public repository.
  static const String secretCode = '1234';
}
```

> ⚠️ **Never commit your real API key to a public repository.** Add `lib/config/env.dart` to `.gitignore` and use `lib/config/env.example.dart` as a template.

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Run the App

```bash
# Debug mode
flutter run

# Release mode (Android)
flutter run --release
```

---

## 🔑 Changing the Secret Code

The default secret code is `1234`. To change it:

**Option A — via `env.dart` (recommended):**
```dart
static const String secretCode = '9876'; // your new code
```

**Option B — directly in `calculator_page.dart`:**
```dart
const String _secretCode = '9876'; // top of file
```

The code is validated on `=` press and never displayed in the UI.

---

## 🧪 Running Tests

```bash
# Run all tests
flutter test

# Run a specific test file
flutter test test/features/calculator/secret_code_test.dart

# Run with coverage
flutter test --coverage
```

### Test Coverage
| Area | File |
|------|------|
| Calculator secret code logic | `test/features/calculator/secret_code_test.dart` |
| Movie model JSON parsing | `test/features/movies/movie_model_test.dart` |
| TV Series model JSON parsing | `test/features/tv_series/tv_model_test.dart` |
| Favorites model & logic | `test/features/favorites/favorites_logic_test.dart` |
| Placeholder widget test | `test/widget_test.dart` |

---

## 📱 Building

### Android

```bash
# Debug APK
flutter build apk --debug

# Release APK (requires signing config)
flutter build apk --release

# App Bundle (for Play Store)
flutter build appbundle --release
```

### iOS

```bash
# Open in Xcode for signing
open ios/Runner.xcworkspace

# Build for device
flutter build ios --release
```

> iOS requires a Mac with Xcode installed and a valid Apple Developer account for device builds.

---

## 📡 TMDB API Endpoints Used

| Feature | Endpoint |
|---------|----------|
| Popular Movies | `GET /movie/popular` |
| Top Rated Movies | `GET /movie/top_rated` |
| Now Playing | `GET /movie/now_playing` |
| Upcoming Movies | `GET /movie/upcoming` |
| Trending Movies | `GET /trending/movie/week` |
| Movie Genres | `GET /genre/movie/list` |
| Movies by Genre | `GET /discover/movie?with_genres=` |
| Movie Details | `GET /movie/{id}` |
| Movie Videos | `GET /movie/{id}/videos` |
| Popular TV | `GET /tv/popular` |
| Top Rated TV | `GET /tv/top_rated` |
| Airing Today | `GET /tv/airing_today` |
| On The Air | `GET /tv/on_the_air` |
| Trending TV | `GET /trending/tv/week` |
| TV Genres | `GET /genre/tv/list` |
| TV by Genre | `GET /discover/tv?with_genres=` |
| TV Details | `GET /tv/{id}` |
| TV Videos | `GET /tv/{id}/videos` |
| Search Movies | `GET /search/movie` |
| Search TV | `GET /search/tv` |

---

## 🎬 Play Button

The **Play** button on detail pages opens **trailers only** — it does **not** stream full movies or TV episodes.

**Behavior:**
1. Fetches video list from TMDB `/videos` endpoint
2. Prefers `type == "Trailer"` first
3. Falls back to `type == "Teaser"` if no trailer exists
4. Opens YouTube via `url_launcher` using the video key
5. Shows "No trailer available" if TMDB has no video for that title

> This app does not use any unofficial or unlicensed streaming sources.

---

## 🏷️ TMDB Attribution

> This product uses the TMDB API but is not endorsed or certified by TMDB.

This app is **not** affiliated with, endorsed by, or certified by:
- TMDB (The Movie Database)
- IMDb
- Netflix
- Any movie studio or streaming service

All movie/TV metadata, images, and video links are provided by TMDB under their [API Terms of Use](https://www.themoviedb.org/documentation/api/terms-of-use).

---

## ⚠️ Known Limitations

- **No streaming** — The Play button opens trailers on YouTube only. Full movie/episode streaming is not included.
- **No login** — App is fully local; no user accounts.
- **No backend** — All favorites are stored on-device using Hive.
- **TMDB image availability** — Some older or less popular titles may have missing posters/backdrops; placeholder images are shown instead.
- **YouTube deep link** — Trailer playback requires the YouTube app or a browser; in-app video player is not included in this MVP.
- **Secret code security** — The secret code is stored in the app config and is not cryptographically secure. It is intended as a casual privacy measure, not a security control.

---

## 🔮 Future Improvements

- [ ] In-app YouTube player (using `youtube_player_flutter`)
- [ ] Cast and crew section on detail pages
- [ ] Similar movies/series recommendations
- [ ] Push notifications for upcoming releases
- [ ] Multiple secret code profiles
- [ ] Widget tests for all screens
- [ ] Integration tests with mock HTTP responses
- [ ] Localization / i18n support
- [ ] Tablet layout support

---

## 🛠️ Tech Stack

| Library | Purpose |
|---------|---------|
| `flutter_riverpod` | State management |
| `dio` | HTTP client |
| `go_router` | Navigation / routing |
| `hive_flutter` | Local favorites storage |
| `cached_network_image` | Image caching |
| `url_launcher` | Open YouTube trailers |
| `connectivity_plus` | Network status detection |
| `build_runner` + `hive_generator` | Code generation for Hive adapters |

---

## 📄 License

This project is for educational/personal use only. All movie and TV data is provided by TMDB.
