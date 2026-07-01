import 'package:dio/dio.dart';
import 'package:secret_vault_app/core/network/dio_client.dart';
import 'package:secret_vault_app/features/tv_series/data/models/tv_series_model.dart';
import 'package:secret_vault_app/features/tv_series/domain/entities/episode.dart';
import 'package:secret_vault_app/features/video/domain/entities/video_item.dart';
import 'package:secret_vault_app/shared/models/genre.dart';

/// Handles all TMDB TV series-related API calls.
abstract class TvRemoteDataSource {
  Future<List<TvSeriesModel>> getPopularTv({int page = 1});
  Future<List<TvSeriesModel>> getTopRatedTv({int page = 1});
  Future<List<TvSeriesModel>> getAiringTodayTv({int page = 1});
  Future<List<TvSeriesModel>> getOnTheAirTv({int page = 1});
  Future<List<TvSeriesModel>> getTrendingTv({int page = 1});
  Future<List<TvSeriesModel>> getTvByGenre(int genreId, {int page = 1});
  Future<TvSeriesModel> getTvDetail(int seriesId);
  Future<List<VideoItem>> getTvVideos(int seriesId);
  Future<List<Genre>> getTvGenres();
  Future<List<TvSeriesModel>> searchTv(String query, {int page = 1});
  /// Fetches episodes for a specific season from TMDB.
  Future<List<Episode>> getSeasonEpisodes(int seriesId, int seasonNumber);
}

class TvRemoteDataSourceImpl implements TvRemoteDataSource {
  final Dio _dio;

  TvRemoteDataSourceImpl({Dio? dio}) : _dio = dio ?? DioClient.instance;

  @override
  Future<List<TvSeriesModel>> getPopularTv({int page = 1}) async {
    final response = await _dio.get(
      '/tv/popular',
      queryParameters: {'page': page},
    );
    return _parseTvList(response.data);
  }

  @override
  Future<List<TvSeriesModel>> getTopRatedTv({int page = 1}) async {
    final response = await _dio.get(
      '/tv/top_rated',
      queryParameters: {'page': page},
    );
    return _parseTvList(response.data);
  }

  @override
  Future<List<TvSeriesModel>> getAiringTodayTv({int page = 1}) async {
    final response = await _dio.get(
      '/tv/airing_today',
      queryParameters: {'page': page},
    );
    return _parseTvList(response.data);
  }

  @override
  Future<List<TvSeriesModel>> getOnTheAirTv({int page = 1}) async {
    final response = await _dio.get(
      '/tv/on_the_air',
      queryParameters: {'page': page},
    );
    return _parseTvList(response.data);
  }

  @override
  Future<List<TvSeriesModel>> getTrendingTv({int page = 1}) async {
    final response = await _dio.get(
      '/trending/tv/week',
      queryParameters: {'page': page},
    );
    return _parseTvList(response.data);
  }

  @override
  Future<List<TvSeriesModel>> getTvByGenre(int genreId, {int page = 1}) async {
    final response = await _dio.get(
      '/discover/tv',
      queryParameters: {
        'with_genres': genreId,
        'page': page,
        'sort_by': 'popularity.desc',
      },
    );
    return _parseTvList(response.data);
  }

  @override
  Future<TvSeriesModel> getTvDetail(int seriesId) async {
    final response = await _dio.get('/tv/$seriesId');
    return TvSeriesModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<VideoItem>> getTvVideos(int seriesId) async {
    final response = await _dio.get('/tv/$seriesId/videos');
    return _parseVideoList(response.data);
  }

  @override
  Future<List<Genre>> getTvGenres() async {
    final response = await _dio.get('/genre/tv/list');
    final data = response.data as Map<String, dynamic>;
    final genres = data['genres'] as List<dynamic>;
    return genres
        .map((g) => Genre.fromJson(g as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<TvSeriesModel>> searchTv(String query, {int page = 1}) async {
    final response = await _dio.get(
      '/search/tv',
      queryParameters: {'query': query, 'page': page},
    );
    return _parseTvList(response.data);
  }

  @override
  Future<List<Episode>> getSeasonEpisodes(int seriesId, int seasonNumber) async {
    final response = await _dio.get('/tv/$seriesId/season/$seasonNumber');
    final data = response.data as Map<String, dynamic>;
    final episodes = data['episodes'] as List<dynamic>? ?? [];
    return episodes.map((e) {
      final map = e as Map<String, dynamic>;
      return Episode(
        id: map['id'] as int,
        episodeNumber: map['episode_number'] as int? ?? 0,
        seasonNumber: map['season_number'] as int? ?? seasonNumber,
        name: map['name'] as String? ?? 'Episode ${map['episode_number']}',
        overview: map['overview'] as String?,
        stillPath: map['still_path'] as String?,
        airDate: map['air_date'] as String?,
        voteAverage: (map['vote_average'] as num?)?.toDouble(),
        runtime: map['runtime'] as int?,
      );
    }).toList();
  }

  List<TvSeriesModel> _parseTvList(dynamic data) {
    final results = (data as Map<String, dynamic>)['results'] as List<dynamic>;
    return results
        .map((item) => TvSeriesModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  List<VideoItem> _parseVideoList(dynamic data) {
    final results = (data as Map<String, dynamic>)['results'] as List<dynamic>;
    return results.map((item) {
      final map = item as Map<String, dynamic>;
      return VideoItem(
        id: map['id'] as String,
        key: map['key'] as String,
        name: map['name'] as String,
        site: map['site'] as String,
        type: map['type'] as String,
        official: map['official'] as bool? ?? false,
      );
    }).toList();
  }
}
