import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:secret_vault_app/core/routing/app_router.dart';
import 'package:secret_vault_app/core/theme/app_theme.dart';
import 'package:secret_vault_app/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:secret_vault_app/features/tv_series/domain/entities/tv_series.dart';
import 'package:secret_vault_app/features/tv_series/presentation/providers/tv_providers.dart';
import 'package:secret_vault_app/shared/widgets/error_view.dart';
import 'package:secret_vault_app/shared/widgets/poster_image.dart';
import 'package:secret_vault_app/shared/widgets/rating_badge.dart';

/// Full-screen TV list for a specific category/genre
class TvListPage extends ConsumerStatefulWidget {
  final String title;
  final String category;
  final int? genreId;

  const TvListPage({
    super.key,
    required this.title,
    required this.category,
    this.genreId,
  });

  @override
  ConsumerState<TvListPage> createState() => _TvListPageState();
}

class _TvListPageState extends ConsumerState<TvListPage> {
  late final StateNotifierProvider<TvListNotifier, TvListState> _provider;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _provider = tvListProvider(widget.category, genreId: widget.genreId);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      ref.read(_provider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(_provider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        title: Text(widget.title,
            style: const TextStyle(color: AppTheme.onBackground)),
      ),
      body: state.series.isEmpty && state.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary))
          : state.series.isEmpty && state.error != null
              ? ErrorView(
                  message: state.error!,
                  onRetry: () => ref.read(_provider.notifier).refresh(),
                )
              : RefreshIndicator(
                  color: AppTheme.primary,
                  onRefresh: () => ref.read(_provider.notifier).refresh(),
                  child: GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.55,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount:
                        state.series.length + (state.isLoading ? 2 : 0),
                    itemBuilder: (context, i) {
                      if (i >= state.series.length) {
                        return _LoadingCard();
                      }
                      return _TvCard(series: state.series[i]);
                    },
                  ),
                ),
    );
  }
}

class _TvCard extends ConsumerWidget {
  final TvSeries series;
  const _TvCard({required this.series});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favNotifier = ref.read(favoritesProvider.notifier);
    final isFav = ref.watch(favoritesProvider
        .select((list) => list.any((f) => f.id == series.id && !f.isMovie)));

    return GestureDetector(
      onTap: () => context.push(AppRoutes.tvDetail(series.id)),
      child: Card(
        color: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                PosterImage(
                    imagePath: series.posterPath,
                    height: 180,
                    width: double.infinity),
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () => favNotifier.toggleTvFavorite(series),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                          color: Colors.black54, shape: BoxShape.circle),
                      child: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? Colors.red : Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(series.name,
                        style: const TextStyle(
                            color: AppTheme.onBackground,
                            fontWeight: FontWeight.w600,
                            fontSize: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        RatingBadge(rating: series.voteAverage, fontSize: 11),
                        const Spacer(),
                        Text(series.firstAirYear,
                            style: const TextStyle(
                                color: AppTheme.onSurfaceVariant,
                                fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
              strokeWidth: 2, color: AppTheme.primary),
        ),
      ),
    );
  }
}
