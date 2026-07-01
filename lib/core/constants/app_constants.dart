import 'package:secret_vault_app/config/env.dart';

/// Application-wide constants
class AppConstants {
  AppConstants._();

  // API
  static const String apiKey = Env.tmdbApiKey;
  static const String baseUrl = Env.tmdbBaseUrl;
  static const String imageBaseUrl = Env.tmdbImageBaseUrl;

  // Image sizes
  static const String posterSize = '/w342';
  static const String backdropSize = '/w780';
  static const String thumbnailSize = '/w185';
  static const String originalSize = '/original';

  // Full image URLs
  static String posterUrl(String? path) =>
      path != null ? '$imageBaseUrl$posterSize$path' : '';
  static String backdropUrl(String? path) =>
      path != null ? '$imageBaseUrl$backdropSize$path' : '';
  static String thumbnailUrl(String? path) =>
      path != null ? '$imageBaseUrl$thumbnailSize$path' : '';

  // YouTube
  static String youtubeUrl(String key) =>
      'https://www.youtube.com/watch?v=$key';
  static String youtubeThumbnail(String key) =>
      'https://img.youtube.com/vi/$key/hqdefault.jpg';

  // Pagination
  static const int defaultPage = 1;
  static const int pageSize = 20;

  // Timeouts
  static const int connectTimeoutMs = 15000;
  static const int receiveTimeoutMs = 15000;

  // Hive box names
  static const String favoritesBoxName = 'favorites';
  static const String watchHistoryBoxName = 'watch_history';

  // Calculator
  static const String secretCode = Env.calculatorSecretCode;
}
