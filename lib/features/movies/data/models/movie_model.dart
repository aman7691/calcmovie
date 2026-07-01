import 'package:secret_vault_app/features/movies/domain/entities/movie.dart';
import 'package:secret_vault_app/shared/models/genre.dart';

/// Data model for TMDB movie API responses.
/// Extends [Movie] domain entity and handles JSON parsing.
class MovieModel extends Movie {
  const MovieModel({
    required super.id,
    required super.title,
    super.posterPath,
    super.backdropPath,
    required super.voteAverage,
    super.releaseDate,
    super.overview,
    super.genreIds,
    super.genres,
    super.originalLanguage,
    super.runtime,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    // genreIds is present in list endpoints, genres in detail endpoint
    final genreIds = (json['genre_ids'] as List<dynamic>?)
            ?.map((e) => e as int)
            .toList() ??
        [];
    final genres = (json['genres'] as List<dynamic>?)
            ?.map((e) => Genre.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return MovieModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? json['name'] as String? ?? 'Unknown',
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      releaseDate: json['release_date'] as String?,
      overview: json['overview'] as String?,
      genreIds: genreIds,
      genres: genres,
      originalLanguage: json['original_language'] as String?,
      runtime: json['runtime'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'poster_path': posterPath,
        'backdrop_path': backdropPath,
        'vote_average': voteAverage,
        'release_date': releaseDate,
        'overview': overview,
        'genre_ids': genreIds,
        'original_language': originalLanguage,
        'runtime': runtime,
      };
}
