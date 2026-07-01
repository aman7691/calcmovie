import 'package:dio/dio.dart';
import 'package:secret_vault_app/core/network/dio_client.dart';
import 'package:secret_vault_app/features/movies/data/models/movie_model.dart';
import 'package:secret_vault_app/features/video/domain/entities/video_item.dart';
import 'package:secret_vault_app/shared/models/genre.dart';

/// Handles all TMDB movie-related API calls.
abstract class MovieRemoteDataSource {
  Future<List<MovieModel>> getPopularMovies({int page = 1});
  Future<List<MovieModel>> getTopRatedMovies({int page = 1});
  Future<List<MovieModel>> getNowPlayingMovies({int page = 1});
  Future<List<MovieModel>> getUpcomingMovies({int page = 1});
  Future<List<MovieModel>> getTrendingMovies({int page = 1});
  Future<List<MovieModel>> getMoviesByGenre(int genreId, {int page = 1});
  Future<List<MovieModel>> getMoviesByCountry(String countryCode, {int page = 1});
  Future<MovieModel> getMovieDetail(int movieId);
  Future<List<VideoItem>> getMovieVideos(int movieId);
  Future<List<MovieModel>> getMovieRecommendations(int movieId, {int page = 1});
  Future<List<Genre>> getMovieGenres();
  Future<List<MovieModel>> searchMovies(String query, {int page = 1});
}

class MovieRemoteDataSourceImpl implements MovieRemoteDataSource {
  final Dio _dio;

  MovieRemoteDataSourceImpl({Dio? dio}) : _dio = dio ?? DioClient.instance;

  @override
  Future<List<MovieModel>> getPopularMovies({int page = 1}) async {
    final response = await _dio.get(
      '/movie/popular',
      queryParameters: {'page': page},
    );
    return _parseMovieList(response.data);
  }

  @override
  Future<List<MovieModel>> getTopRatedMovies({int page = 1}) async {
    final response = await _dio.get(
      '/movie/top_rated',
      queryParameters: {'page': page},
    );
    return _parseMovieList(response.data);
  }

  @override
  Future<List<MovieModel>> getNowPlayingMovies({int page = 1}) async {
    final response = await _dio.get(
      '/movie/now_playing',
      queryParameters: {'page': page},
    );
    return _parseMovieList(response.data);
  }

  @override
  Future<List<MovieModel>> getUpcomingMovies({int page = 1}) async {
    final response = await _dio.get(
      '/movie/upcoming',
      queryParameters: {'page': page},
    );
    return _parseMovieList(response.data);
  }

  @override
  Future<List<MovieModel>> getTrendingMovies({int page = 1}) async {
    final response = await _dio.get(
      '/trending/movie/week',
      queryParameters: {'page': page},
    );
    return _parseMovieList(response.data);
  }

  @override
  Future<List<MovieModel>> getMoviesByGenre(int genreId, {int page = 1}) async {
    final response = await _dio.get(
      '/discover/movie',
      queryParameters: {
        'with_genres': genreId,
        'page': page,
        'sort_by': 'popularity.desc',
      },
    );
    return _parseMovieList(response.data);
  }

  @override
  Future<MovieModel> getMovieDetail(int movieId) async {
    final response = await _dio.get('/movie/$movieId');
    return MovieModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<MovieModel>> getMoviesByCountry(String countryCode, {int page = 1}) async {
    // TMDB discover endpoint: filter by origin_country (ISO 3166-1 alpha-2, e.g. "US", "KR", "TH")
    final response = await _dio.get(
      '/discover/movie',
      queryParameters: {
        'with_origin_country': countryCode,
        'page': page,
        'sort_by': 'popularity.desc',
      },
    );
    return _parseMovieList(response.data);
  }

  @override
  Future<List<VideoItem>> getMovieVideos(int movieId) async {
    final response = await _dio.get('/movie/$movieId/videos');
    return _parseVideoList(response.data);
  }

  @override
  Future<List<MovieModel>> getMovieRecommendations(int movieId, {int page = 1}) async {
    // TMDB recommendations endpoint — returns movies similar to the given movie
    final response = await _dio.get(
      '/movie/$movieId/recommendations',
      queryParameters: {'page': page},
    );
    return _parseMovieList(response.data);
  }

  @override
  Future<List<Genre>> getMovieGenres() async {
    final response = await _dio.get('/genre/movie/list');
    final data = response.data as Map<String, dynamic>;
    final genres = data['genres'] as List<dynamic>;
    return genres
        .map((g) => Genre.fromJson(g as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<MovieModel>> searchMovies(String query, {int page = 1}) async {
    final response = await _dio.get(
      '/search/movie',
      queryParameters: {'query': query, 'page': page},
    );
    return _parseMovieList(response.data);
  }

  List<MovieModel> _parseMovieList(dynamic data) {
    final results = (data as Map<String, dynamic>)['results'] as List<dynamic>;
    return results
        .map((item) => MovieModel.fromJson(item as Map<String, dynamic>))
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
