import 'package:secret_vault_app/shared/models/genre.dart';

/// Domain entity representing a movie
class Movie {
  final int id;
  final String title;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final String? releaseDate;
  final String? overview;
  final List<int> genreIds;
  final List<Genre> genres;
  final String? originalLanguage;
  final int? runtime;

  const Movie({
    required this.id,
    required this.title,
    this.posterPath,
    this.backdropPath,
    required this.voteAverage,
    this.releaseDate,
    this.overview,
    this.genreIds = const [],
    this.genres = const [],
    this.originalLanguage,
    this.runtime,
  });

  /// Release year extracted from releaseDate (YYYY-MM-DD format)
  String get releaseYear {
    if (releaseDate == null || releaseDate!.isEmpty) return 'N/A';
    return releaseDate!.split('-').first;
  }

  /// Rating formatted to 1 decimal
  String get ratingText => voteAverage > 0
      ? voteAverage.toStringAsFixed(1)
      : 'N/A';

  /// Runtime formatted as "Xh Ym"
  String get runtimeText {
    if (runtime == null || runtime == 0) return 'N/A';
    final h = runtime! ~/ 60;
    final m = runtime! % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Movie && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
