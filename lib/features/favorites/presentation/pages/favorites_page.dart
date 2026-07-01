import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:secret_vault_app/core/routing/app_router.dart';
import 'package:secret_vault_app/core/theme/app_theme.dart';
import 'package:secret_vault_app/features/favorites/data/models/favorite_item_model.dart';
import 'package:secret_vault_app/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:secret_vault_app/features/history/data/models/watch_history_model.dart';
import 'package:secret_vault_app/features/history/presentation/providers/watch_history_provider.dart';
import 'package:secret_vault_app/shared/widgets/error_view.dart'
    show EmptyView;
import 'package:secret_vault_app/shared/widgets/poster_image.dart';
import 'package:secret_vault_app/shared/widgets/rating_badge.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final history = ref.watch(watchHistoryProvider);

    final hasContent = favorites.isNotEmpty || history.isNotEmpty;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        title: const Text('Favorites',
            style: TextStyle(color: AppTheme.onBackground)),
        actions: [
          if (favorites.isNotEmpty)
            TextButton(
              onPressed: () => _confirmClearAll(context, ref),
              child: const Text('Clear All',
                  style: TextStyle(color: AppTheme.primary)),
            ),
        ],
      ),
      body: !hasContent
          ? const EmptyView(
              message: 'No favorites yet.\nTap the heart icon to save items.',
              icon: Icons.favorite_outline,
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                // ── Continue Watching ─────────────────────────────────────
                if (history.isNotEmpty) ...[
                  _SectionHeader(
                    title: 'Continue Watching',
                    trailing: TextButton(
                      onPressed: () =>
                          ref.read(watchHistoryProvider.notifier).clearAll(),
                      child: const Text('Clear',
                          style: TextStyle(
                              color: AppTheme.onSurfaceVariant,
                              fontSize: 12)),
                    ),
                  ),
                  SizedBox(
                    height: 195,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: history.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: 10),
                      itemBuilder: (context, i) =>
                          _HistoryCard(item: history[i]),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(
                      color: AppTheme.surface, indent: 16, endIndent: 16),
                ],

                // ── Favorites list ────────────────────────────────────────
                if (favorites.isNotEmpty) ...[
                  const _SectionHeader(title: 'My Favorites'),
                  ...favorites.map(
                    (item) => _FavoriteItemTile(item: item),
                  ),
                ],
              ],
            ),
    );
  }

  void _confirmClearAll(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Clear Favorites',
            style: TextStyle(color: AppTheme.onBackground)),
        content: const Text('Remove all favorites?',
            style: TextStyle(color: AppTheme.onSurfaceVariant)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () {
              ref.read(favoritesProvider.notifier).clearAll();
              Navigator.pop(ctx);
            },
            child: const Text('Clear',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ─── Section header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const _SectionHeader({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 12, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppTheme.onBackground,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ─── Continue Watching horizontal card ───────────────────────────────────────

class _HistoryCard extends ConsumerWidget {
  final WatchHistoryModel item;
  const _HistoryCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        if (item.isMovie) {
          context.push(AppRoutes.movieDetail(item.id));
        } else {
          context.push(AppRoutes.tvDetail(item.id));
        }
      },
      child: SizedBox(
        width: 110,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: PosterImage(
                    imagePath: item.posterPath,
                    width: 110,
                    height: 145,
                    fit: BoxFit.cover,
                  ),
                ),
                // Play overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.black26,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.play_circle_outline,
                        color: Colors.white, size: 36),
                  ),
                ),
                // Type badge
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: item.isMovie
                          ? AppTheme.primary.withValues(alpha: 0.85)
                          : Colors.teal.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.isMovie ? 'Movie' : 'TV',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              item.title,
              style: const TextStyle(
                color: AppTheme.onBackground,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              item.watchedAtLabel,
              style: const TextStyle(
                  color: AppTheme.onSurfaceVariant, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Favorites list tile ─────────────────────────────────────────────────────

class _FavoriteItemTile extends ConsumerWidget {
  final FavoriteItemModel item;
  const _FavoriteItemTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favNotifier = ref.read(favoritesProvider.notifier);

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      onTap: () {
        if (item.isMovie) {
          context.push(AppRoutes.movieDetail(item.id));
        } else {
          context.push(AppRoutes.tvDetail(item.id));
        }
      },
      leading: PosterImage(
        imagePath: item.posterPath,
        width: 50,
        height: 75,
        borderRadius: BorderRadius.circular(6),
      ),
      title: Text(
        item.title,
        style: const TextStyle(
            color: AppTheme.onBackground, fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: item.isMovie
                      ? AppTheme.primary.withValues(alpha: 0.2)
                      : Colors.teal.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  item.isMovie ? 'Movie' : 'TV Series',
                  style: TextStyle(
                    color: item.isMovie ? AppTheme.primary : Colors.teal,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (item.releaseYear != null)
                Text(item.releaseYear!,
                    style: const TextStyle(
                        color: AppTheme.onSurfaceVariant, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 4),
          RatingBadge(rating: item.voteAverage, fontSize: 12),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.favorite, color: Colors.red),
        onPressed: () => favNotifier.removeById(item.id, item.isMovie),
      ),
    );
  }
}
