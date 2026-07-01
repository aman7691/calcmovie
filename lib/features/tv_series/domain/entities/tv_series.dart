import 'package:secret_vault_app/shared/models/genre.dart';

/// Domain entity representing a TV series
class TvSeries {
  final int id;
  final String name;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final String? firstAirDate;
  final String? lastAirDate;
  final String? overview;
  final List<int> genreIds;
  final List<Genre> genres;
  final String? originalLanguage;
  final int? numberOfSeasons;
  final int? numberOfEpisodes;
  final String? status;

  const TvSeries({
    required this.id,
    required this.name,
    this.posterPath,
    this.backdropPath,
    required this.voteAverage,
    this.firstAirDate,
    this.lastAirDate,
    this.overview,
    this.genreIds = const [],
    this.genres = const [],
    this.originalLanguage,
    this.numberOfSeasons,
    this.numberOfEpisodes,
    this.status,
  });

  /// First air year extracted from firstAirDate (YYYY-MM-DD format)
  String get firstAirYear {
    if (firstAirDate == null || firstAirDate!.isEmpty) return 'N/A';
    return firstAirDate!.split('-').first;
  }

  /// Rating formatted to 1 decimal
  String get ratingText => voteAverage > 0
      ? voteAverage.toStringAsFixed(1)
      : 'N/A';

  /// Seasons text
  String get seasonsText {
    if (numberOfSeasons == null) return 'N/A';
    return '$numberOfSeasons ${numberOfSeasons == 1 ? "Season" : "Seasons"}';
  }

  /// Episodes text
  String get episodesText {
    if (numberOfEpisodes == null) return 'N/A';
    return '$numberOfEpisodes ${numberOfEpisodes == 1 ? "Episode" : "Episodes"}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is TvSeries && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
