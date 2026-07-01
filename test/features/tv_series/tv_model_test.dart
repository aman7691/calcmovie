import 'package:flutter_test/flutter_test.dart';
import 'package:secret_vault_app/features/tv_series/data/models/tv_series_model.dart';

void main() {
  group('TvSeriesModel - JSON parsing', () {
    final sampleJson = {
      'id': 1396,
      'name': 'Breaking Bad',
      'overview': 'A high school chemistry teacher diagnosed with lung cancer...',
      'poster_path': '/ggFHVNu6YYI5L9pCfOacjizRGt.jpg',
      'backdrop_path': '/tsRy63Mu5cu8etL1X7ZLyf7UP1M.jpg',
      'vote_average': 9.5,
      'vote_count': 12000,
      'first_air_date': '2008-01-20',
      'genre_ids': [18, 80],
      'original_language': 'en',
      'popularity': 200.0,
      'number_of_seasons': 5,
      'number_of_episodes': 62,
      'status': 'Ended',
      'last_air_date': '2013-09-29',
    };

    test('parses id correctly', () {
      final series = TvSeriesModel.fromJson(sampleJson);
      expect(series.id, 1396);
    });

    test('parses name correctly', () {
      final series = TvSeriesModel.fromJson(sampleJson);
      expect(series.name, 'Breaking Bad');
    });

    test('parses voteAverage correctly', () {
      final series = TvSeriesModel.fromJson(sampleJson);
      expect(series.voteAverage, 9.5);
    });

    test('parses firstAirDate correctly', () {
      final series = TvSeriesModel.fromJson(sampleJson);
      expect(series.firstAirDate, '2008-01-20');
    });

    test('parses posterPath correctly', () {
      final series = TvSeriesModel.fromJson(sampleJson);
      expect(series.posterPath, '/ggFHVNu6YYI5L9pCfOacjizRGt.jpg');
    });

    test('parses numberOfSeasons correctly', () {
      final series = TvSeriesModel.fromJson(sampleJson);
      expect(series.numberOfSeasons, 5);
    });

    test('parses numberOfEpisodes correctly', () {
      final series = TvSeriesModel.fromJson(sampleJson);
      expect(series.numberOfEpisodes, 62);
    });

    test('parses status correctly', () {
      final series = TvSeriesModel.fromJson(sampleJson);
      expect(series.status, 'Ended');
    });

    test('parses lastAirDate correctly', () {
      final series = TvSeriesModel.fromJson(sampleJson);
      expect(series.lastAirDate, '2013-09-29');
    });

    test('handles null posterPath gracefully', () {
      final json = Map<String, dynamic>.from(sampleJson);
      json['poster_path'] = null;
      final series = TvSeriesModel.fromJson(json);
      expect(series.posterPath, isNull);
    });

    test('handles missing overview gracefully', () {
      final json = Map<String, dynamic>.from(sampleJson);
      json.remove('overview');
      final series = TvSeriesModel.fromJson(json);
      expect(series.overview, isNull);
    });

    test('firstAirYear returns year from firstAirDate', () {
      final series = TvSeriesModel.fromJson(sampleJson);
      expect(series.firstAirYear, '2008');
    });

    test('firstAirYear returns fallback for null firstAirDate', () {
      final json = Map<String, dynamic>.from(sampleJson);
      json['first_air_date'] = null;
      final series = TvSeriesModel.fromJson(json);
      // firstAirYear is '' or 'N/A' depending on entity implementation
      expect(series.firstAirYear, anyOf('', 'N/A'));
    });

    test('TvSeriesModel extends TvSeries — fields accessible as entity', () {
      final series = TvSeriesModel.fromJson(sampleJson);
      expect(series.id, 1396);
      expect(series.name, 'Breaking Bad');
    });
  });
}
