import 'package:hive_flutter/hive_flutter.dart';

part 'favorite_item_model.g.dart';

/// Hive type IDs - must be unique across the app
/// 0 = FavoriteItemModel

@HiveType(typeId: 0)
class FavoriteItemModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? posterPath;

  @HiveField(3)
  final double voteAverage;

  @HiveField(4)
  final String? releaseDate;

  @HiveField(5)
  final String? overview;

  @HiveField(6)
  final bool isMovie; // true = movie, false = TV series

  @HiveField(7)
  final String? backdropPath;

  FavoriteItemModel({
    required this.id,
    required this.title,
    this.posterPath,
    required this.voteAverage,
    this.releaseDate,
    this.overview,
    required this.isMovie,
    this.backdropPath,
  });

  /// Returns just the year portion of releaseDate (e.g. "2023")
  String? get releaseYear {
    if (releaseDate == null || releaseDate!.isEmpty) return null;
    return releaseDate!.split('-').first;
  }
}
