import 'package:flutter_test/flutter_test.dart';
import 'package:secret_vault_app/features/movies/data/models/movie_model.dart';

void main() {
  group('MovieModel - JSON parsing', () {
    final sampleJson = {
      'id': 550,
      'title': 'Fight Club',
      'overview': 'A ticking-time-bomb insomniac...',
      'poster_path': '/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg',
      'backdrop_path': '/hZkgoQYus5vegHoetLkCJzb17zJ.jpg',
      'vote_average': 8.4,
      'vote_count': 26280,
      'release_date': '1999-10-15',
      'genre_ids': [18, 53],
      'original_language': 'en',
      'popularity': 61.4,
    };

    test('parses id correctly', () {
      final movie = MovieModel.fromJson(sampleJson);
      expect(movie.id, 550);
    });

    test('parses title correctly', () {
      final movie = MovieModel.fromJson(sampleJson);
      expect(movie.title, 'Fight Club');
    });

    test('parses voteAverage correctly', () {
      final movie = MovieModel.fromJson(sampleJson);
      expect(movie.voteAverage, 8.4);
    });

    test('parses releaseDate correctly', () {
      final movie = MovieModel.fromJson(sampleJson);
      expect(movie.releaseDate, '1999-10-15');
    });

    test('parses posterPath correctly', () {
      final movie = MovieModel.fromJson(sampleJson);
      expect(movie.posterPath, '/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg');
    });

    test('parses backdropPath correctly', () {
      final movie = MovieModel.fromJson(sampleJson);
      expect(movie.backdropPath, '/hZkgoQYus5vegHoetLkCJzb17zJ.jpg');
    });

    test('parses overview correctly', () {
      final movie = MovieModel.fromJson(sampleJson);
      expect(movie.overview, 'A ticking-time-bomb insomniac...');
    });

    test('handles null posterPath gracefully', () {
      final json = Map<String, dynamic>.from(sampleJson);
      json['poster_path'] = null;
      final movie = MovieModel.fromJson(json);
      expect(movie.posterPath, isNull);
    });

    test('handles null backdropPath gracefully', () {
      final json = Map<String, dynamic>.from(sampleJson);
      json['backdrop_path'] = null;
      final movie = MovieModel.fromJson(json);
      expect(movie.backdropPath, isNull);
    });

    test('handles missing overview gracefully', () {
      final json = Map<String, dynamic>.from(sampleJson);
      json.remove('overview');
      final movie = MovieModel.fromJson(json);
      expect(movie.overview, isNull);
    });

    test('releaseYear returns year from releaseDate', () {
      final movie = MovieModel.fromJson(sampleJson);
      expect(movie.releaseYear, '1999');
    });

    test('releaseYear returns fallback for null releaseDate', () {
      final json = Map<String, dynamic>.from(sampleJson);
      json['release_date'] = null;
      final movie = MovieModel.fromJson(json);
      // releaseYear is '' or 'N/A' depending on entity implementation
      expect(movie.releaseYear, anyOf('', 'N/A'));
    });

    test('MovieModel extends Movie — fields accessible as entity', () {
      // MovieModel extends Movie directly; no separate toEntity() needed
      final movie = MovieModel.fromJson(sampleJson);
      expect(movie.id, 550);
      expect(movie.title, 'Fight Club');
      expect(movie.voteAverage, 8.4);
    });

    test('toJson round-trips id and title', () {
      final movie = MovieModel.fromJson(sampleJson);
      final json = movie.toJson();
      expect(json['id'], 550);
      expect(json['title'], 'Fight Club');
    });
  });
}
