import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:secret_vault_app/core/routing/app_router.dart';
import 'package:secret_vault_app/core/theme/app_theme.dart';
import 'package:secret_vault_app/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:secret_vault_app/features/history/presentation/providers/watch_history_provider.dart';
import 'package:secret_vault_app/features/movies/domain/entities/movie.dart';
import 'package:secret_vault_app/features/movies/presentation/providers/movie_providers.dart';
import 'package:secret_vault_app/features/video/domain/entities/video_item.dart';
import 'package:secret_vault_app/features/video/presentation/widgets/play_button.dart';
import 'package:secret_vault_app/shared/widgets/error_view.dart';
import 'package:secret_vault_app/shared/widgets/poster_image.dart';
import 'package:secret_vault_app/shared/widgets/rating_badge.dart';

class MovieDetailPage extends ConsumerWidget {
  final int movieId;
  const MovieDetailPage({super.key, required this.movieId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movieAsync = ref.watch(movieDetailProvider(movieId));
    final videosAsync = ref.watch(movieVideosProvider(movieId));

    return movieAsync.when(
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
      data: (movie) => _MovieDetailContent(
        movie: movie,
        videosAsync: videosAsync,
      ),
    );
  }
}

class _MovieDetailContent extends ConsumerWidget {
  final Movie movie;
  final AsyncValue<List<VideoItem>> videosAsync;

  const _MovieDetailContent({
    required this.movie,
    required this.videosAsync,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favNotifier = ref.read(favoritesProvider.notifier);
    final historyNotifier = ref.read(watchHistoryProvider.notifier);
    final isFav = ref.watch(favoritesProvider
        .select((list) => list.any((f) => f.id == movie.id && f.isMovie)));

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // ── App bar with backdrop ─────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppTheme.surface,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  PosterImage(
                    imagePath: movie.backdropPath ?? movie.posterPath,
                    isBackdrop: movie.backdropPath != null,
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
                onPressed: () => favNotifier.toggleMovieFavorite(movie),
              ),
            ],
          ),

          // ── Content ───────────────────────────────────────────────────────
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
                        imagePath: movie.posterPath,
                        width: 100,
                        height: 150,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              movie.title,
                              style: const TextStyle(
                                color: AppTheme.onBackground,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            RatingBadge(rating: movie.voteAverage, fontSize: 14),
                            const SizedBox(height: 6),
                            _MetaRow(
                                icon: Icons.calendar_today_outlined,
                                text: movie.releaseDate ?? 'Unknown'),
                            if (movie.runtime != null && movie.runtime! > 0)
                              _MetaRow(
                                  icon: Icons.timer_outlined,
                                  text: movie.runtimeText),
                            _MetaRow(
                                icon: Icons.language,
                                text: (movie.originalLanguage ?? 'N/A')
                                    .toUpperCase()),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Genres
                  if (movie.genres.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: movie.genres
                          .map((g) => Chip(
                                label: Text(g.name,
                                    style: const TextStyle(fontSize: 12)),
                                backgroundColor: AppTheme.surface,
                                labelStyle: const TextStyle(
                                    color: AppTheme.onBackground),
                                side:
                                    const BorderSide(color: AppTheme.primary),
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
                    movie.overview?.isNotEmpty == true
                        ? movie.overview!
                        : 'No overview available.',
                    style: const TextStyle(
                        color: AppTheme.onSurfaceVariant,
                        fontSize: 14,
                        height: 1.5),
                  ),

                  // ── Play Trailer ─────────────────────────────────────────
                  const SizedBox(height: 20),
                  videosAsync.when(
                    loading: () =>
                        const PlayButton(videos: [], isLoading: true),
                    error: (_, __) => const PlayButton(videos: []),
                    data: (videos) => PlayButton(videos: videos),
                  ),

                  // ── Watch Now — records to Continue Watching ─────────────
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
                        'Watch Now',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        // Record this movie in Continue Watching history
                        historyNotifier.addMovie(movie);
                        context.push(
                          AppRoutes.player(
                            tmdbId: movie.id,
                            title: movie.title,
                            isMovie: true,
                          ),
                        );
                      },
                    ),
                  ),

                  // ── Recommended Movies ────────────────────────────────────
                  const SizedBox(height: 28),
                  _RecommendedSection(movieId: movie.id),

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
            child: Text(
              text,
              style: const TextStyle(
                  color: AppTheme.onSurfaceVariant, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Recommended Movies horizontal section ────────────────────────────────────

class _RecommendedSection extends ConsumerWidget {
  final int movieId;
  const _RecommendedSection({required this.movieId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recsAsync = ref.watch(movieRecommendationsProvider(movieId));

    return recsAsync.when(
      loading: () => const SizedBox(
        height: 180,
        child: Center(
            child: CircularProgressIndicator(color: AppTheme.primary)),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (movies) {
        if (movies.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recommended',
              style: TextStyle(
                color: AppTheme.onBackground,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 190,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: movies.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, i) =>
                    _RecommendedCard(movie: movies[i]),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RecommendedCard extends StatelessWidget {
  final Movie movie;
  const _RecommendedCard({required this.movie});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.movieDetail(movie.id)),
      child: SizedBox(
        width: 110,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: PosterImage(
                imagePath: movie.posterPath,
                width: 110,
                height: 145,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              movie.title,
              style: const TextStyle(
                color: AppTheme.onBackground,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            RatingBadge(rating: movie.voteAverage, fontSize: 10),
          ],
        ),
      ),
    );
  }
}
