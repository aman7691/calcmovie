import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:secret_vault_app/features/video/domain/entities/video_item.dart';

/// Reusable full-width Play Trailer button.
/// Matches the same size/style as the "Watch Now" button.
/// IMPORTANT: Only plays official trailers/teasers from TMDB via YouTube.
/// Does NOT stream full movies or episodes.
class PlayButton extends ConsumerWidget {
  final List<VideoItem> videos;
  final bool isLoading;

  const PlayButton({
    super.key,
    required this.videos,
    this.isLoading = false,
  });

  /// Picks the best video to play:
  /// 1. Official trailer on YouTube
  /// 2. Any trailer on YouTube
  /// 3. Official teaser on YouTube
  /// 4. Any YouTube video
  VideoItem? _getBestVideo() {
    if (videos.isEmpty) return null;
    final youtube = videos.where((v) => v.isYouTube).toList();
    if (youtube.isEmpty) return null;

    // 1. Official trailer
    final officialTrailer = youtube
        .where((v) => v.official && v.type.toLowerCase() == 'trailer')
        .toList();
    if (officialTrailer.isNotEmpty) return officialTrailer.first;

    // 2. Any trailer
    final anyTrailer =
        youtube.where((v) => v.type.toLowerCase() == 'trailer').toList();
    if (anyTrailer.isNotEmpty) return anyTrailer.first;

    // 3. Official teaser
    final officialTeaser = youtube
        .where((v) => v.official && v.type.toLowerCase() == 'teaser')
        .toList();
    if (officialTeaser.isNotEmpty) return officialTeaser.first;

    // 4. Any YouTube video
    return youtube.first;
  }

  Future<void> _playTrailer(BuildContext context) async {
    final video = _getBestVideo();
    if (video == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No trailer available.')),
      );
      return;
    }

    final url = Uri.parse(video.youtubeUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Could not open trailer. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bestVideo = _getBestVideo();
    final hasTrailer = bestVideo != null;

    // Full-width button — same layout/size as the Watch Now button
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isLoading
            ? null
            : hasTrailer
                ? () => _playTrailer(context)
                : null,
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : Icon(
                hasTrailer ? Icons.play_circle_outline : Icons.play_disabled,
                size: 22,
              ),
        label: Text(
          isLoading
              ? 'Loading...'
              : hasTrailer
                  ? 'Play Trailer'
                  : 'No Trailer Available',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              hasTrailer ? const Color(0xFFE50914) : const Color(0xFF505050),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
