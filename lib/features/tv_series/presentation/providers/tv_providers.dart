import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:secret_vault_app/features/tv_series/data/datasources/tv_remote_datasource.dart';
import 'package:secret_vault_app/features/tv_series/data/repositories/tv_repository_impl.dart';
import 'package:secret_vault_app/features/tv_series/domain/entities/episode.dart';
import 'package:secret_vault_app/features/tv_series/domain/entities/tv_series.dart';
import 'package:secret_vault_app/features/tv_series/domain/repositories/tv_repository.dart';
import 'package:secret_vault_app/features/video/domain/entities/video_item.dart';
import 'package:secret_vault_app/shared/models/genre.dart';

// ─── Dependency Providers ─────────────────────────────────────────────────────

final tvDataSourceProvider = Provider<TvRemoteDataSource>((ref) {
  return TvRemoteDataSourceImpl();
});

final tvRepositoryProvider = Provider<TvRepository>((ref) {
  return TvRepositoryImpl(
    remoteDataSource: ref.read(tvDataSourceProvider),
  );
});

// ─── Data Providers ───────────────────────────────────────────────────────────

final tvGenresProvider = FutureProvider<List<Genre>>((ref) async {
  return ref.read(tvRepositoryProvider).getTvGenres();
});

final tvDetailProvider =
    FutureProvider.family<TvSeries, int>((ref, seriesId) async {
  return ref.read(tvRepositoryProvider).getTvDetail(seriesId);
});

final tvVideosProvider =
    FutureProvider.family<List<VideoItem>, int>((ref, seriesId) async {
  return ref.read(tvRepositoryProvider).getTvVideos(seriesId);
});

// ─── Paginated TV List Notifier ───────────────────────────────────────────────

class TvListState {
  final List<TvSeries> series;
  final bool isLoading;
  final bool hasMore;
  final String? error;
  final int currentPage;

  const TvListState({
    this.series = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.error,
    this.currentPage = 0,
  });

  TvListState copyWith({
    List<TvSeries>? series,
    bool? isLoading,
    bool? hasMore,
    String? error,
    int? currentPage,
  }) {
    return TvListState(
      series: series ?? this.series,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

typedef TvFetcher = Future<List<TvSeries>> Function(int page);

class TvListNotifier extends StateNotifier<TvListState> {
  final TvFetcher _fetcher;

  TvListNotifier(this._fetcher) : super(const TvListState()) {
    loadMore();
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final nextPage = state.currentPage + 1;
      final results = await _fetcher(nextPage);
      state = state.copyWith(
        series: [...state.series, ...results],
        isLoading: false,
        hasMore: results.length >= 20,
        currentPage: nextPage,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    state = const TvListState();
    await loadMore();
  }
}

/// Provider for fetching episodes of a specific season.
/// Family key is a record (seriesId, seasonNumber).
final tvSeasonEpisodesProvider = FutureProvider.family<List<Episode>, (int, int)>(
  (ref, params) async {
    final (seriesId, seasonNumber) = params;
    return ref.read(tvRepositoryProvider).getSeasonEpisodes(seriesId, seasonNumber);
  },
);

/// Factory for creating TV list providers by category
StateNotifierProvider<TvListNotifier, TvListState> tvListProvider(
    String category,
    {int? genreId}) {
  return StateNotifierProvider<TvListNotifier, TvListState>(
    (ref) {
      final repo = ref.read(tvRepositoryProvider);
      TvFetcher fetcher;
      switch (category) {
        case 'popular':
          fetcher = (p) => repo.getPopularTv(page: p);
        case 'top_rated':
          fetcher = (p) => repo.getTopRatedTv(page: p);
        case 'airing_today':
          fetcher = (p) => repo.getAiringTodayTv(page: p);
        case 'on_the_air':
          fetcher = (p) => repo.getOnTheAirTv(page: p);
        case 'trending':
          fetcher = (p) => repo.getTrendingTv(page: p);
        case 'genre':
          fetcher = (p) => repo.getTvByGenre(genreId!, page: p);
        default:
          fetcher = (p) => repo.getPopularTv(page: p);
      }
      return TvListNotifier(fetcher);
    },
  );
}
