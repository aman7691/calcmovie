/// Domain entity representing a single TV episode from TMDB.
class Episode {
  final int id;
  final int episodeNumber;
  final int seasonNumber;
  final String name;
  final String? overview;
  final String? stillPath;     // thumbnail image path
  final String? airDate;
  final double? voteAverage;
  final int? runtime;          // runtime in minutes (may be null)

  const Episode({
    required this.id,
    required this.episodeNumber,
    required this.seasonNumber,
    required this.name,
    this.overview,
    this.stillPath,
    this.airDate,
    this.voteAverage,
    this.runtime,
  });

  /// Returns the air year extracted from [airDate] or empty string.
  String get airYear {
    if (airDate == null || airDate!.isEmpty) return '';
    return airDate!.split('-').first;
  }
}
