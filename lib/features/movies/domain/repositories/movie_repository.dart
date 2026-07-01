import 'package:secret_vault_app/features/movies/domain/entities/movie.dart';
import 'package:secret_vault_app/features/video/domain/entities/video_item.dart';
import 'package:secret_vault_app/shared/models/genre.dart';

/// Abstract repository for movie operations (domain layer contract)
abstract class MovieRepository {
  Future<List<Movie>> getPopularMovies({int page = 1});
  Future<List<Movie>> getTopRatedMovies({int page = 1});
  Future<List<Movie>> getNowPlayingMovies({int page = 1});
  Future<List<Movie>> getUpcomingMovies({int page = 1});
  Future<List<Movie>> getTrendingMovies({int page = 1});
  Future<List<Movie>> getMoviesByGenre(int genreId, {int page = 1});
  Future<List<Movie>> getMoviesByCountry(String countryCode, {int page = 1});
  Future<Movie> getMovieDetail(int movieId);
  Future<List<VideoItem>> getMovieVideos(int movieId);
  Future<List<Movie>> getMovieRecommendations(int movieId, {int page = 1});
  Future<List<Genre>> getMovieGenres();
  Future<List<Movie>> searchMovies(String query, {int page = 1});
}
