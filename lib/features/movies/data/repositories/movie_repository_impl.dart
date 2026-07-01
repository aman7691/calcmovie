import 'package:secret_vault_app/core/errors/exceptions.dart' as app_exceptions;
import 'package:secret_vault_app/core/errors/failures.dart';
import 'package:secret_vault_app/features/movies/data/datasources/movie_remote_datasource.dart';
import 'package:secret_vault_app/features/movies/domain/entities/movie.dart';
import 'package:secret_vault_app/features/movies/domain/repositories/movie_repository.dart';
import 'package:secret_vault_app/features/video/domain/entities/video_item.dart';
import 'package:secret_vault_app/shared/models/genre.dart';

/// Concrete implementation of [MovieRepository].
/// Catches datasource exceptions and rethrows as domain [Failure]s.
class MovieRepositoryImpl implements MovieRepository {
  final MovieRemoteDataSource _remoteDataSource;

  MovieRepositoryImpl({required MovieRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<List<Movie>> getPopularMovies({int page = 1}) =>
      _execute(() => _remoteDataSource.getPopularMovies(page: page));

  @override
  Future<List<Movie>> getTopRatedMovies({int page = 1}) =>
      _execute(() => _remoteDataSource.getTopRatedMovies(page: page));

  @override
  Future<List<Movie>> getNowPlayingMovies({int page = 1}) =>
      _execute(() => _remoteDataSource.getNowPlayingMovies(page: page));

  @override
  Future<List<Movie>> getUpcomingMovies({int page = 1}) =>
      _execute(() => _remoteDataSource.getUpcomingMovies(page: page));

  @override
  Future<List<Movie>> getTrendingMovies({int page = 1}) =>
      _execute(() => _remoteDataSource.getTrendingMovies(page: page));

  @override
  Future<List<Movie>> getMoviesByGenre(int genreId, {int page = 1}) =>
      _execute(() => _remoteDataSource.getMoviesByGenre(genreId, page: page));

  @override
  Future<List<Movie>> getMoviesByCountry(String countryCode, {int page = 1}) =>
      _execute(() => _remoteDataSource.getMoviesByCountry(countryCode, page: page));

  @override
  Future<Movie> getMovieDetail(int movieId) =>
      _execute(() => _remoteDataSource.getMovieDetail(movieId));

  @override
  Future<List<VideoItem>> getMovieVideos(int movieId) =>
      _execute(() => _remoteDataSource.getMovieVideos(movieId));

  @override
  Future<List<Movie>> getMovieRecommendations(int movieId, {int page = 1}) =>
      _execute(() => _remoteDataSource.getMovieRecommendations(movieId, page: page));

  @override
  Future<List<Genre>> getMovieGenres() =>
      _execute(() => _remoteDataSource.getMovieGenres());

  @override
  Future<List<Movie>> searchMovies(String query, {int page = 1}) =>
      _execute(() => _remoteDataSource.searchMovies(query, page: page));

  /// Wraps async calls, catching typed exceptions and rethrowing as [Failure]s.
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
