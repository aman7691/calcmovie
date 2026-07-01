import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:secret_vault_app/features/movies/data/datasources/movie_remote_datasource.dart';
import 'package:secret_vault_app/features/movies/data/models/movie_model.dart';
import 'package:secret_vault_app/features/tv_series/data/datasources/tv_remote_datasource.dart';
import 'package:secret_vault_app/features/tv_series/data/models/tv_series_model.dart';

/// Unified search result item
class SearchResult {
  final int id;
  final String title;
  final String? posterPath;
  final double voteAverage;
  final String? releaseYear;
  final bool isMovie;

  const SearchResult({
    required this.id,
    required this.title,
    this.posterPath,
    required this.voteAverage,
    this.releaseYear,
    required this.isMovie,
  });
}

/// State for the search feature
class SearchState {
  final String query;
  final List<SearchResult> results;
  final bool isLoading;
  final String? error;

  const SearchState({
    this.query = '',
    this.results = const [],
    this.isLoading = false,
    this.error,
  });

  SearchState copyWith({
    String? query,
    List<SearchResult>? results,
    bool? isLoading,
    String? error,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  final MovieRemoteDataSource _movieDataSource;
  final TvRemoteDataSource _tvDataSource;

  SearchNotifier({
    required MovieRemoteDataSource movieDataSource,
    required TvRemoteDataSource tvDataSource,
  })  : _movieDataSource = movieDataSource,
        _tvDataSource = tvDataSource,
        super(const SearchState());

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = const SearchState();
      return;
    }

    state = state.copyWith(query: query, isLoading: true, error: null, results: []);

    try {
      // Search movies and TV series in parallel
      final results = await Future.wait([
        _movieDataSource.searchMovies(query),
        _tvDataSource.searchTv(query),
      ]);

      final movies = results[0] as List<MovieModel>;
      final tvShows = results[1] as List<TvSeriesModel>;

      final combined = <SearchResult>[
        ...movies.map((m) => SearchResult(
              id: m.id,
              title: m.title,
              posterPath: m.posterPath,
              voteAverage: m.voteAverage,
              releaseYear: m.releaseYear,
              isMovie: true,
            )),
        ...tvShows.map((t) => SearchResult(
              id: t.id,
              title: t.name,
              posterPath: t.posterPath,
              voteAverage: t.voteAverage,
              releaseYear: t.firstAirYear,
              isMovie: false,
            )),
      ];

      state = state.copyWith(
        results: combined,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Search failed. Please try again.',
      );
    }
  }

  void clear() {
    state = const SearchState();
  }
}

final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier(
    movieDataSource: MovieRemoteDataSourceImpl(),
    tvDataSource: TvRemoteDataSourceImpl(),
  );
});
