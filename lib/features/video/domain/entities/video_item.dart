/// Domain entity for a video/trailer item from TMDB
class VideoItem {
  final String id;
  final String key;       // YouTube video key
  final String name;
  final String site;      // Usually "YouTube"
  final String type;      // "Trailer", "Teaser", "Clip", etc.
  final bool official;

  const VideoItem({
    required this.id,
    required this.key,
    required this.name,
    required this.site,
    required this.type,
    required this.official,
  });

  /// Whether this video can be played on YouTube
  bool get isYouTube => site.toLowerCase() == 'youtube';

  /// YouTube watch URL
  String get youtubeUrl => 'https://www.youtube.com/watch?v=$key';

  /// YouTube thumbnail URL
  String get youtubeThumbnail =>
      'https://img.youtube.com/vi/$key/hqdefault.jpg';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is VideoItem && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
