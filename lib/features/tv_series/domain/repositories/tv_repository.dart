import 'package:secret_vault_app/features/tv_series/domain/entities/episode.dart';
import 'package:secret_vault_app/features/tv_series/domain/entities/tv_series.dart';
import 'package:secret_vault_app/features/video/domain/entities/video_item.dart';
import 'package:secret_vault_app/shared/models/genre.dart';

/// Abstract repository for TV series operations (domain layer contract)
abstract class TvRepository {
  Future<List<TvSeries>> getPopularTv({int page = 1});
  Future<List<TvSeries>> getTopRatedTv({int page = 1});
  Future<List<TvSeries>> getAiringTodayTv({int page = 1});
  Future<List<TvSeries>> getOnTheAirTv({int page = 1});
  Future<List<TvSeries>> getTrendingTv({int page = 1});
  Future<List<TvSeries>> getTvByGenre(int genreId, {int page = 1});
  Future<TvSeries> getTvDetail(int seriesId);
  Future<List<VideoItem>> getTvVideos(int seriesId);
  Future<List<Genre>> getTvGenres();
  Future<List<TvSeries>> searchTv(String query, {int page = 1});
  /// Returns episodes for [seriesId] season [seasonNumber].
  Future<List<Episode>> getSeasonEpisodes(int seriesId, int seasonNumber);
}
