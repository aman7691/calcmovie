import 'package:secret_vault_app/features/tv_series/domain/entities/tv_series.dart';
import 'package:secret_vault_app/shared/models/genre.dart';

/// Data model for TMDB TV series API responses.
/// Extends [TvSeries] domain entity and handles JSON parsing.
class TvSeriesModel extends TvSeries {
  const TvSeriesModel({
    required super.id,
    required super.name,
    super.posterPath,
    super.backdropPath,
    required super.voteAverage,
    super.firstAirDate,
    super.lastAirDate,
    super.overview,
    super.genreIds,
    super.genres,
    super.originalLanguage,
    super.numberOfSeasons,
    super.numberOfEpisodes,
    super.status,
  });

  factory TvSeriesModel.fromJson(Map<String, dynamic> json) {
    final genreIds = (json['genre_ids'] as List<dynamic>?)
            ?.map((e) => e as int)
            .toList() ??
        [];
    final genres = (json['genres'] as List<dynamic>?)
            ?.map((e) => Genre.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return TvSeriesModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? json['title'] as String? ?? 'Unknown',
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      firstAirDate: json['first_air_date'] as String?,
      lastAirDate: json['last_air_date'] as String?,
      overview: json['overview'] as String?,
      genreIds: genreIds,
      genres: genres,
      originalLanguage: json['original_language'] as String?,
      numberOfSeasons: json['number_of_seasons'] as int?,
      numberOfEpisodes: json['number_of_episodes'] as int?,
      status: json['status'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'poster_path': posterPath,
        'backdrop_path': backdropPath,
        'vote_average': voteAverage,
        'first_air_date': firstAirDate,
        'last_air_date': lastAirDate,
        'overview': overview,
        'genre_ids': genreIds,
        'original_language': originalLanguage,
        'number_of_seasons': numberOfSeasons,
        'number_of_episodes': numberOfEpisodes,
        'status': status,
      };
}
