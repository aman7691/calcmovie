import 'package:hive_flutter/hive_flutter.dart';

part 'watch_history_model.g.dart';

/// Hive type IDs:
///   0 = FavoriteItemModel
///   1 = WatchHistoryModel  ← this file

@HiveType(typeId: 1)
class WatchHistoryModel extends HiveObject {
  /// TMDB id of the movie or TV series
  @HiveField(0)
  final int id;

  /// Display title / series name
  @HiveField(1)
  final String title;

  /// TMDB poster path (nullable — handled gracefully)
  @HiveField(2)
  final String? posterPath;

  /// true = movie, false = TV series
  @HiveField(3)
  final bool isMovie;

  /// ISO-8601 timestamp when the user last opened the player
  @HiveField(4)
  final String watchedAt;

  /// Vote average (rating) – stored so we can display it offline
  @HiveField(5)
  final double voteAverage;

  WatchHistoryModel({
    required this.id,
    required this.title,
    this.posterPath,
    required this.isMovie,
    required this.watchedAt,
    required this.voteAverage,
  });

  /// Human-readable "watched" label
  String get watchedAtLabel {
    try {
      final dt = DateTime.parse(watchedAt).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inHours < 1) return '${diff.inMinutes}m ago';
      if (diff.inDays < 1) return '${diff.inHours}h ago';
      if (diff.inDays == 1) return 'Yesterday';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return '';
    }
  }
}
