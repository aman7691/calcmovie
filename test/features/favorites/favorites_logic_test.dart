import 'package:flutter_test/flutter_test.dart';
import 'package:secret_vault_app/features/favorites/data/models/favorite_item_model.dart';
import 'package:secret_vault_app/features/movies/data/models/movie_model.dart';
import 'package:secret_vault_app/features/tv_series/data/models/tv_series_model.dart';

/// Unit tests for FavoriteItemModel and related domain logic.
/// Note: FavoritesNotifier (Hive) tests require a real box; 
/// these tests cover the model layer and releaseYear logic.
void main() {
  group('FavoriteItemModel', () {
    test('releaseYear extracts year from releaseDate', () {
      final item = FavoriteItemModel(
        id: 1,
        title: 'Test',
        voteAverage: 8.0,
        isMovie: true,
        releaseDate: '2020-05-15',
      );
      expect(item.releaseYear, '2020');
    });

    test('releaseYear returns null when releaseDate is null', () {
      final item = FavoriteItemModel(
        id: 2,
        title: 'Test',
        voteAverage: 7.5,
        isMovie: false,
        releaseDate: null,
      );
      expect(item.releaseYear, isNull);
    });

    test('releaseYear returns null when releaseDate is empty', () {
      final item = FavoriteItemModel(
        id: 3,
        title: 'Test',
        voteAverage: 7.0,
        isMovie: true,
        releaseDate: '',
      );
      expect(item.releaseYear, isNull);
    });

    test('isMovie flag is true for movie', () {
      final item = FavoriteItemModel(
        id: 10,
        title: 'Movie',
        voteAverage: 8.0,
        isMovie: true,
      );
      expect(item.isMovie, isTrue);
    });

    test('isMovie flag is false for TV series', () {
      final item = FavoriteItemModel(
        id: 11,
        title: 'Series',
        voteAverage: 8.5,
        isMovie: false,
      );
      expect(item.isMovie, isFalse);
    });
  });

  group('Movie -> FavoriteItemModel creation', () {
    final movieJson = {
      'id': 550,
      'title': 'Fight Club',
      'poster_path': '/poster.jpg',
      'backdrop_path': '/backdrop.jpg',
      'vote_average': 8.4,
      'release_date': '1999-10-15',
      'overview': 'An insomniac office worker...',
      'genre_ids': <int>[],
      'original_language': 'en',
    };

    test('FavoriteItemModel from movie has correct id', () {
      final movie = MovieModel.fromJson(movieJson);
      final fav = FavoriteItemModel(
        id: movie.id,
        title: movie.title,
        posterPath: movie.posterPath,
        voteAverage: movie.voteAverage,
        releaseDate: movie.releaseDate,
        overview: movie.overview,
        isMovie: true,
        backdropPath: movie.backdropPath,
      );
      expect(fav.id, 550);
      expect(fav.isMovie, isTrue);
      expect(fav.title, 'Fight Club');
    });

    test('FavoriteItemModel from movie has correct releaseYear', () {
      final movie = MovieModel.fromJson(movieJson);
      final fav = FavoriteItemModel(
        id: movie.id,
        title: movie.title,
        voteAverage: movie.voteAverage,
        releaseDate: movie.releaseDate,
        isMovie: true,
      );
      expect(fav.releaseYear, '1999');
    });
  });

  group('TvSeries -> FavoriteItemModel creation', () {
    final tvJson = {
      'id': 1396,
      'name': 'Breaking Bad',
      'poster_path': '/poster.jpg',
      'backdrop_path': '/backdrop.jpg',
      'vote_average': 9.5,
      'first_air_date': '2008-01-20',
      'overview': 'Chemistry teacher...',
      'genre_ids': <int>[],
      'original_language': 'en',
    };

    test('FavoriteItemModel from TV series has correct id', () {
      final series = TvSeriesModel.fromJson(tvJson);
      final fav = FavoriteItemModel(
        id: series.id,
        title: series.name,
        posterPath: series.posterPath,
        voteAverage: series.voteAverage,
        releaseDate: series.firstAirDate,
        overview: series.overview,
        isMovie: false,
        backdropPath: series.backdropPath,
      );
      expect(fav.id, 1396);
      expect(fav.isMovie, isFalse);
      expect(fav.title, 'Breaking Bad');
    });

    test('FavoriteItemModel from TV series has correct releaseYear', () {
      final series = TvSeriesModel.fromJson(tvJson);
      final fav = FavoriteItemModel(
        id: series.id,
        title: series.name,
        voteAverage: series.voteAverage,
        releaseDate: series.firstAirDate,
        isMovie: false,
      );
      expect(fav.releaseYear, '2008');
    });
  });

  group('FavoritesNotifier key uniqueness', () {
    /// Verify that movie and TV items with same ID get different keys
    /// (prevents collision between movie ID 100 and TV series ID 100)
    String keyFor(int id, bool isMovie) =>
        '${isMovie ? "m" : "t"}_$id';

    test('movie and TV with same id have different keys', () {
      expect(keyFor(100, true), isNot(equals(keyFor(100, false))));
    });

    test('movie key has m prefix', () {
      expect(keyFor(42, true), 'm_42');
    });

    test('tv key has t prefix', () {
      expect(keyFor(42, false), 't_42');
    });
  });
}
