import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:secret_vault_app/core/constants/app_constants.dart';
import 'package:secret_vault_app/core/routing/app_router.dart';
import 'package:secret_vault_app/core/theme/app_theme.dart';
import 'package:secret_vault_app/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:secret_vault_app/features/history/presentation/providers/watch_history_provider.dart';
import 'package:secret_vault_app/features/tv_series/domain/entities/episode.dart';
import 'package:secret_vault_app/features/tv_series/domain/entities/tv_series.dart';
import 'package:secret_vault_app/features/tv_series/presentation/providers/tv_providers.dart';
import 'package:secret_vault_app/features/video/domain/entities/video_item.dart';
import 'package:secret_vault_app/features/video/presentation/widgets/play_button.dart';
import 'package:secret_vault_app/shared/widgets/error_view.dart';
import 'package:secret_vault_app/shared/widgets/poster_image.dart';
import 'package:secret_vault_app/shared/widgets/rating_badge.dart';

class TvSeriesDetailPage extends ConsumerWidget {
  final int seriesId;
  const TvSeriesDetailPage({super.key, required this.seriesId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seriesAsync = ref.watch(tvDetailProvider(seriesId));
    final videosAsync = ref.watch(tvVideosProvider(seriesId));

    return seriesAsync.when(
      loading: () => Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(backgroundColor: AppTheme.surface),
        body: const Center(
            child: CircularProgressIndicator(color: AppTheme.primary)),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(backgroundColor: AppTheme.surface),
        body: ErrorView(message: e.toString()),
      ),
      data: (series) =>
          _TvDetailContent(series: series, videosAsync: videosAsync),
    );
  }
}

class _TvDetailContent extends ConsumerStatefulWidget {
  final TvSeries series;
  final AsyncValue<List<VideoItem>> videosAsync;

  const _TvDetailContent({
    required this.series,
    required this.videosAsync,
  });

  @override
  ConsumerState<_TvDetailContent> createState() => _TvDetailContentState();
}

class _TvDetailContentState extends ConsumerState<_TvDetailContent> {
  /// Currently selected season number (1-based). Defaults to season 1.
  int _selectedSeason = 1;

  @override
  Widget build(BuildContext context) {
    final series = widget.series;
    final favNotifier = ref.read(favoritesProvider.notifier);
    final historyNotifier = ref.read(watchHistoryProvider.notifier);
    final isFav = ref.watch(favoritesProvider
        .select((list) => list.any((f) => f.id == series.id && !f.isMovie)));

    final totalSeasons = series.numberOfSeasons ?? 0;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // ── Backdrop / AppBar ─────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppTheme.surface,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  PosterImage(
                    imagePath: series.backdropPath ?? series.posterPath,
                    isBackdrop: series.backdropPath != null,
                    fit: BoxFit.cover,
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, AppTheme.background],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.red : Colors.white,
                ),
                onPressed: () => favNotifier.toggleTvFavorite(series),
              ),
            ],
          ),

          // ── Series info ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PosterImage(
                        imagePath: series.posterPath,
                        width: 100,
                        height: 150,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(series.name,
                                style: const TextStyle(
                                    color: AppTheme.onBackground,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            RatingBadge(
                                rating: series.voteAverage, fontSize: 14),
                            const SizedBox(height: 6),
                            _MetaRow(
                                icon: Icons.calendar_today_outlined,
                                text: series.firstAirDate ?? 'Unknown'),
                            if (series.lastAirDate != null)
                              _MetaRow(
                                  icon: Icons.event_available,
                                  text: 'Last: ${series.lastAirDate!}'),
                            if (series.numberOfSeasons != null)
                              _MetaRow(
                                  icon: Icons.layers_outlined,
                                  text:
                                      '${series.numberOfSeasons} Season(s)'),
                            if (series.numberOfEpisodes != null)
                              _MetaRow(
                                  icon: Icons.play_lesson_outlined,
                                  text:
                                      '${series.numberOfEpisodes} Episode(s)'),
                            if (series.status != null)
                              _MetaRow(
                                  icon: Icons.info_outline,
                                  text: series.status!),
                            _MetaRow(
                                icon: Icons.language,
                                text: (series.originalLanguage ?? 'N/A')
                                    .toUpperCase()),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Genres
                  if (series.genres.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: series.genres
                          .map((g) => Chip(
                                label: Text(g.name,
                                    style: const TextStyle(fontSize: 12)),
                                backgroundColor: AppTheme.surface,
                                labelStyle: const TextStyle(
                                    color: AppTheme.onBackground),
                                side: const BorderSide(
                                    color: AppTheme.primary),
                                padding: EdgeInsets.zero,
                              ))
                          .toList(),
                    ),
                  ],

                  // Overview
                  const SizedBox(height: 16),
                  const Text('Overview',
                      style: TextStyle(
                          color: AppTheme.onBackground,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    series.overview?.isNotEmpty == true
                        ? series.overview!
                        : 'No overview available.',
                    style: const TextStyle(
                        color: AppTheme.onSurfaceVariant,
                        fontSize: 14,
                        height: 1.5),
                  ),

                  // Play trailer
                  const SizedBox(height: 20),
                  widget.videosAsync.when(
                    loading: () =>
                        const PlayButton(videos: [], isLoading: true),
                    error: (_, __) => const PlayButton(videos: []),
                    data: (videos) => PlayButton(videos: videos),
                  ),

                  // ── Watch Now (vidsrc streaming — S1 E1 by default) ───────
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.play_circle_fill, size: 22),
                      label: const Text(
                        'Watch Now  (S1 · E1)',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        // Record this series in Continue Watching history
                        historyNotifier.addTvSeries(series);
                        context.push(
                          AppRoutes.player(
                            tmdbId: series.id,
                            title: series.name,
                            isMovie: false,
                            season: 1,
                            episode: 1,
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Season / Episodes section ─────────────────────────────
                  if (totalSeasons > 0) ...[
                    const Divider(color: AppTheme.surface),
                    const SizedBox(height: 8),
                    const Text(
                      'Episodes',
                      style: TextStyle(
                          color: AppTheme.onBackground,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    // Season selector chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(totalSeasons, (i) {
                          final seasonNum = i + 1;
                          final selected = _selectedSeason == seasonNum;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text('Season $seasonNum'),
                              selected: selected,
                              onSelected: (_) => setState(
                                  () => _selectedSeason = seasonNum),
                              selectedColor: AppTheme.primary,
                              backgroundColor: AppTheme.surface,
                              labelStyle: TextStyle(
                                color: selected
                                    ? Colors.black
                                    : AppTheme.onSurfaceVariant,
                                fontWeight: selected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              side: BorderSide(
                                color: selected
                                    ? AppTheme.primary
                                    : AppTheme.surface,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Episodes list for the selected season
                    _EpisodesList(
                      seriesId: series.id,
                      seriesName: series.name,
                      seasonNumber: _selectedSeason,
                    ),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Episodes List Widget ─────────────────────────────────────────────────────

class _EpisodesList extends ConsumerWidget {
  final int seriesId;
  final String seriesName;
  final int seasonNumber;

  const _EpisodesList({
    required this.seriesId,
    required this.seriesName,
    required this.seasonNumber,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final episodesAsync =
        ref.watch(tvSeasonEpisodesProvider((seriesId, seasonNumber)));

    return episodesAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
            child: CircularProgressIndicator(color: AppTheme.primary)),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: ErrorView(
          message: 'Could not load episodes: $e',
          onRetry: () => ref.invalidate(
              tvSeasonEpisodesProvider((seriesId, seasonNumber))),
        ),
      ),
      data: (episodes) {
        if (episodes.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                'No episodes found for this season.',
                style: TextStyle(color: AppTheme.onSurfaceVariant),
              ),
            ),
          );
        }
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: episodes.length,
          separatorBuilder: (_, __) =>
              const Divider(color: AppTheme.surface, height: 1),
          itemBuilder: (context, index) => _EpisodeTile(
            episode: episodes[index],
            seriesId: seriesId,
            seriesName: seriesName,
            seasonNumber: seasonNumber,
          ),
        );
      },
    );
  }
}

// ─── Episode Tile ─────────────────────────────────────────────────────────────

class _EpisodeTile extends StatelessWidget {
  final Episode episode;
  final int seriesId;
  final String seriesName;
  final int seasonNumber;

  const _EpisodeTile({
    required this.episode,
    required this.seriesId,
    required this.seriesName,
    required this.seasonNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Still / thumbnail — tapping opens the player
          GestureDetector(
            onTap: () => context.push(
              AppRoutes.player(
                tmdbId: seriesId,
                title: seriesName,
                isMovie: false,
                season: seasonNumber,
                episode: episode.episodeNumber,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: episode.stillPath != null
                      ? Image.network(
                          '${AppConstants.imageBaseUrl}${AppConstants.backdropSize}${episode.stillPath}',
                          width: 120,
                          height: 68,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _NoStillPlaceholder(),
                        )
                      : _NoStillPlaceholder(),
                ),
                // Play icon overlay
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.play_arrow,
                      color: Colors.white, size: 20),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Episode info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'E${episode.episodeNumber}  ${episode.name}',
                  style: const TextStyle(
                    color: AppTheme.onBackground,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (episode.voteAverage != null &&
                        episode.voteAverage! > 0) ...[
                      const Icon(Icons.star,
                          color: Colors.amber, size: 13),
                      const SizedBox(width: 2),
                      Text(
                        episode.voteAverage!.toStringAsFixed(1),
                        style: const TextStyle(
                            color: AppTheme.onSurfaceVariant,
                            fontSize: 12),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (episode.airDate != null &&
                        episode.airDate!.isNotEmpty)
                      Text(
                        episode.airDate!,
                        style: const TextStyle(
                            color: AppTheme.onSurfaceVariant,
                            fontSize: 11),
                      ),
                    if (episode.runtime != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        '${episode.runtime}m',
                        style: const TextStyle(
                            color: AppTheme.onSurfaceVariant,
                            fontSize: 11),
                      ),
                    ],
                  ],
                ),
                if (episode.overview != null &&
                    episode.overview!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    episode.overview!,
                    style: const TextStyle(
                        color: AppTheme.onSurfaceVariant, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                // Watch Episode button
                const SizedBox(height: 6),
                SizedBox(
                  height: 30,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: const Icon(Icons.play_arrow, size: 14),
                    label: const Text('Watch',
                        style: TextStyle(fontSize: 12)),
                    onPressed: () => context.push(
                      AppRoutes.player(
                        tmdbId: seriesId,
                        title: seriesName,
                        isMovie: false,
                        season: seasonNumber,
                        episode: episode.episodeNumber,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NoStillPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 68,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Icon(Icons.movie_outlined,
          color: AppTheme.onSurfaceVariant, size: 28),
    );
  }
}

// ─── Shared _MetaRow ──────────────────────────────────────────────────────────

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _MetaRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppTheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    color: AppTheme.onSurfaceVariant, fontSize: 13),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
