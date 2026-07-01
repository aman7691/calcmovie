import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:secret_vault_app/features/movies/data/datasources/movie_remote_datasource.dart';
import 'package:secret_vault_app/features/movies/data/repositories/movie_repository_impl.dart';
import 'package:secret_vault_app/features/movies/domain/entities/movie.dart';
import 'package:secret_vault_app/features/movies/domain/repositories/movie_repository.dart';
import 'package:secret_vault_app/features/video/domain/entities/video_item.dart';
import 'package:secret_vault_app/shared/models/genre.dart';

// ─── Dependency Providers ─────────────────────────────────────────────────────

final movieDataSourceProvider = Provider<MovieRemoteDataSource>((ref) {
  return MovieRemoteDataSourceImpl();
});

final movieRepositoryProvider = Provider<MovieRepository>((ref) {
  return MovieRepositoryImpl(
    remoteDataSource: ref.read(movieDataSourceProvider),
  );
});

// ─── Data Providers ───────────────────────────────────────────────────────────

final movieGenresProvider = FutureProvider<List<Genre>>((ref) async {
  return ref.read(movieRepositoryProvider).getMovieGenres();
});

final popularMoviesProvider =
    FutureProvider.family<List<Movie>, int>((ref, page) async {
  return ref.read(movieRepositoryProvider).getPopularMovies(page: page);
});

final topRatedMoviesProvider =
    FutureProvider.family<List<Movie>, int>((ref, page) async {
  return ref.read(movieRepositoryProvider).getTopRatedMovies(page: page);
});

final nowPlayingMoviesProvider =
    FutureProvider.family<List<Movie>, int>((ref, page) async {
  return ref.read(movieRepositoryProvider).getNowPlayingMovies(page: page);
});

final upcomingMoviesProvider =
    FutureProvider.family<List<Movie>, int>((ref, page) async {
  return ref.read(movieRepositoryProvider).getUpcomingMovies(page: page);
});

final trendingMoviesProvider =
    FutureProvider.family<List<Movie>, int>((ref, page) async {
  return ref.read(movieRepositoryProvider).getTrendingMovies(page: page);
});

final moviesByGenreProvider =
    FutureProvider.family<List<Movie>, ({int genreId, int page})>(
        (ref, params) async {
  return ref
      .read(movieRepositoryProvider)
      .getMoviesByGenre(params.genreId, page: params.page);
});

final movieDetailProvider =
    FutureProvider.family<Movie, int>((ref, movieId) async {
  return ref.read(movieRepositoryProvider).getMovieDetail(movieId);
});

final movieVideosProvider =
    FutureProvider.family<List<VideoItem>, int>((ref, movieId) async {
  return ref.read(movieRepositoryProvider).getMovieVideos(movieId);
});

/// Fetches TMDB recommendations for a given movie id.
final movieRecommendationsProvider =
    FutureProvider.family<List<Movie>, int>((ref, movieId) async {
  return ref.read(movieRepositoryProvider).getMovieRecommendations(movieId);
});

/// Fetches movies filtered by origin country code (ISO 3166-1 alpha-2).
final moviesByCountryProvider =
    FutureProvider.family<List<Movie>, ({String countryCode, int page})>(
        (ref, params) async {
  return ref
      .read(movieRepositoryProvider)
      .getMoviesByCountry(params.countryCode, page: params.page);
});

// ─── Paginated Movie List Notifier ────────────────────────────────────────────

/// State for a paginated movie list
class MovieListState {
  final List<Movie> movies;
  final bool isLoading;
  final bool hasMore;
  final String? error;
  final int currentPage;

  const MovieListState({
    this.movies = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.error,
    this.currentPage = 0,
  });

  MovieListState copyWith({
    List<Movie>? movies,
    bool? isLoading,
    bool? hasMore,
    String? error,
    int? currentPage,
  }) {
    return MovieListState(
      movies: movies ?? this.movies,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

typedef MovieFetcher = Future<List<Movie>> Function(int page);

class MovieListNotifier extends StateNotifier<MovieListState> {
  final MovieFetcher _fetcher;

  MovieListNotifier(this._fetcher) : super(const MovieListState()) {
    loadMore();
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final nextPage = state.currentPage + 1;
      final results = await _fetcher(nextPage);
      state = state.copyWith(
        movies: [...state.movies, ...results],
        isLoading: false,
        hasMore: results.length >= 20,
        currentPage: nextPage,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    state = const MovieListState();
    await loadMore();
  }
}

/// Factory for creating movie list providers by category or country.
/// Pass category='country' and countryCode='KR' for country-filtered lists.
StateNotifierProvider<MovieListNotifier, MovieListState>
    movieListProvider(String category, {int? genreId, String? countryCode}) {
  return StateNotifierProvider<MovieListNotifier, MovieListState>(
    (ref) {
      final repo = ref.read(movieRepositoryProvider);
      MovieFetcher fetcher;
      switch (category) {
        case 'popular':
          fetcher = (p) => repo.getPopularMovies(page: p);
        case 'top_rated':
          fetcher = (p) => repo.getTopRatedMovies(page: p);
        case 'now_playing':
          fetcher = (p) => repo.getNowPlayingMovies(page: p);
        case 'upcoming':
          fetcher = (p) => repo.getUpcomingMovies(page: p);
        case 'trending':
          fetcher = (p) => repo.getTrendingMovies(page: p);
        case 'genre':
          fetcher = (p) => repo.getMoviesByGenre(genreId!, page: p);
        case 'country':
          fetcher = (p) => repo.getMoviesByCountry(countryCode!, page: p);
        default:
          fetcher = (p) => repo.getPopularMovies(page: p);
      }
      return MovieListNotifier(fetcher);
    },
  );
}
