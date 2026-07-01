import 'package:secret_vault_app/core/errors/exceptions.dart' as app_exceptions;
import 'package:secret_vault_app/core/errors/failures.dart';
import 'package:secret_vault_app/features/tv_series/data/datasources/tv_remote_datasource.dart';
import 'package:secret_vault_app/features/tv_series/domain/entities/episode.dart';
import 'package:secret_vault_app/features/tv_series/domain/entities/tv_series.dart';
import 'package:secret_vault_app/features/tv_series/domain/repositories/tv_repository.dart';
import 'package:secret_vault_app/features/video/domain/entities/video_item.dart';
import 'package:secret_vault_app/shared/models/genre.dart';

/// Concrete implementation of [TvRepository].
class TvRepositoryImpl implements TvRepository {
  final TvRemoteDataSource _remoteDataSource;

  TvRepositoryImpl({required TvRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<List<TvSeries>> getPopularTv({int page = 1}) =>
      _execute(() => _remoteDataSource.getPopularTv(page: page));

  @override
  Future<List<TvSeries>> getTopRatedTv({int page = 1}) =>
      _execute(() => _remoteDataSource.getTopRatedTv(page: page));

  @override
  Future<List<TvSeries>> getAiringTodayTv({int page = 1}) =>
      _execute(() => _remoteDataSource.getAiringTodayTv(page: page));

  @override
  Future<List<TvSeries>> getOnTheAirTv({int page = 1}) =>
      _execute(() => _remoteDataSource.getOnTheAirTv(page: page));

  @override
  Future<List<TvSeries>> getTrendingTv({int page = 1}) =>
      _execute(() => _remoteDataSource.getTrendingTv(page: page));

  @override
  Future<List<TvSeries>> getTvByGenre(int genreId, {int page = 1}) =>
      _execute(() => _remoteDataSource.getTvByGenre(genreId, page: page));

  @override
  Future<TvSeries> getTvDetail(int seriesId) =>
      _execute(() => _remoteDataSource.getTvDetail(seriesId));

  @override
  Future<List<VideoItem>> getTvVideos(int seriesId) =>
      _execute(() => _remoteDataSource.getTvVideos(seriesId));

  @override
  Future<List<Genre>> getTvGenres() =>
      _execute(() => _remoteDataSource.getTvGenres());

  @override
  Future<List<TvSeries>> searchTv(String query, {int page = 1}) =>
      _execute(() => _remoteDataSource.searchTv(query, page: page));

  @override
  Future<List<Episode>> getSeasonEpisodes(int seriesId, int seasonNumber) =>
      _execute(() => _remoteDataSource.getSeasonEpisodes(seriesId, seasonNumber));

  Future<T> _execute<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on app_exceptions.NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on app_exceptions.TimeoutException catch (e) {
      throw TimeoutFailure(e.message);
    } on app_exceptions.UnauthorizedException catch (e) {
      throw UnauthorizedFailure(e.message);
    } on app_exceptions.ServerException catch (e) {
      throw ServerFailure(message: e.message, statusCode: e.statusCode);
    } catch (e) {
      throw UnexpectedFailure(e.toString());
    }
  }
}
