import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:secret_vault_app/features/calculator/presentation/calculator_page.dart';
import 'package:secret_vault_app/features/movies/presentation/pages/movies_page.dart';
import 'package:secret_vault_app/features/movies/presentation/pages/movie_detail_page.dart';
import 'package:secret_vault_app/features/tv_series/presentation/pages/tv_series_page.dart';
import 'package:secret_vault_app/features/tv_series/presentation/pages/tv_series_detail_page.dart';
import 'package:secret_vault_app/features/search/presentation/pages/search_page.dart';
import 'package:secret_vault_app/features/favorites/presentation/pages/favorites_page.dart';
import 'package:secret_vault_app/features/movies/presentation/pages/movie_list_page.dart';
import 'package:secret_vault_app/features/tv_series/presentation/pages/tv_list_page.dart';
import 'package:secret_vault_app/features/video/presentation/pages/vidsrc_player_page.dart';
import 'package:secret_vault_app/shared/widgets/main_shell.dart';

/// Named routes and route helper methods
class AppRoutes {
  AppRoutes._();
  static const String calculator = '/';
  static const String home = '/home';
  static const String movies = '/home/movies';
  static const String tvSeries = '/home/tv';
  static const String search = '/home/search';
  static const String favorites = '/home/favorites';

  /// Navigate to movie detail: /home/movies/detail/123
  static String movieDetail(int id) => '/home/movies/detail/$id';

  /// Navigate to TV detail: /home/tv/detail/123
  static String tvDetail(int id) => '/home/tv/detail/$id';

  /// Navigate to vidsrc player.
  /// For movies: /player?id=123&title=MovieTitle&isMovie=true
  /// For TV:     /player?id=123&title=ShowTitle&isMovie=false&season=1&episode=2
  static String player({
    required int tmdbId,
    required String title,
    bool isMovie = true,
    int season = 1,
    int episode = 1,
  }) {
    final params = {
      'id': '$tmdbId',
      'title': title,
      'isMovie': '$isMovie',
      'season': '$season',
      'episode': '$episode',
    };
    final query = params.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
    return '/player?$query';
  }
}

/// App router configuration
final appRouter = GoRouter(
  initialLocation: AppRoutes.calculator,
  debugLogDiagnostics: false,
  routes: [
    // Calculator (lock screen)
    GoRoute(
      path: AppRoutes.calculator,
      name: 'calculator',
      builder: (context, state) => const CalculatorPage(),
    ),

    // ── Vidsrc streaming player (outside the shell so it can be full-screen) ──
    GoRoute(
      path: '/player',
      name: 'player',
      builder: (context, state) {
        final tmdbId = int.parse(state.uri.queryParameters['id'] ?? '0');
        final title = state.uri.queryParameters['title'] ?? '';
        final isMovie =
            (state.uri.queryParameters['isMovie'] ?? 'true') == 'true';
        final season = int.tryParse(
                state.uri.queryParameters['season'] ?? '1') ??
            1;
        final episode = int.tryParse(
                state.uri.queryParameters['episode'] ?? '1') ??
            1;
        return VidsrcPlayerPage(
          tmdbId: tmdbId,
          title: title,
          isMovie: isMovie,
          season: season,
          episode: episode,
        );
      },
    ),

    // Main shell with bottom navigation
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.movies,
          name: 'movies',
          builder: (context, state) => const MoviesPage(),
          routes: [
            GoRoute(
              path: 'detail/:id',
              name: 'movieDetail',
              builder: (context, state) {
                final id = int.parse(state.pathParameters['id']!);
                return MovieDetailPage(movieId: id);
              },
            ),
            GoRoute(
              path: 'list',
              name: 'movieList',
              builder: (context, state) {
                final title =
                    state.uri.queryParameters['title'] ?? 'Movies';
                final category =
                    state.uri.queryParameters['category'] ?? 'popular';
                final genreId = state.uri.queryParameters['genreId'];
                return MovieListPage(
                  title: title,
                  category: category,
                  genreId:
                      genreId != null ? int.tryParse(genreId) : null,
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.tvSeries,
          name: 'tvSeries',
          builder: (context, state) => const TvSeriesPage(),
          routes: [
            GoRoute(
              path: 'detail/:id',
              name: 'tvDetail',
              builder: (context, state) {
                final id = int.parse(state.pathParameters['id']!);
                return TvSeriesDetailPage(seriesId: id);
              },
            ),
            GoRoute(
              path: 'list',
              name: 'tvList',
              builder: (context, state) {
                final title =
                    state.uri.queryParameters['title'] ?? 'TV Series';
                final category =
                    state.uri.queryParameters['category'] ?? 'popular';
                final genreId = state.uri.queryParameters['genreId'];
                return TvListPage(
                  title: title,
                  category: category,
                  genreId:
                      genreId != null ? int.tryParse(genreId) : null,
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.search,
          name: 'search',
          builder: (context, state) => const SearchPage(),
        ),
        GoRoute(
          path: AppRoutes.favorites,
          name: 'favorites',
          builder: (context, state) => const FavoritesPage(),
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Page not found: ${state.error}',
          style: const TextStyle(color: Colors.white)),
    ),
  ),
);
