import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:secret_vault_app/core/routing/app_router.dart';
import 'package:secret_vault_app/core/theme/app_theme.dart';
import 'package:secret_vault_app/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:secret_vault_app/features/tv_series/domain/entities/tv_series.dart';
import 'package:secret_vault_app/features/tv_series/presentation/providers/tv_providers.dart';
import 'package:secret_vault_app/shared/models/genre.dart';
import 'package:secret_vault_app/shared/widgets/error_view.dart';
import 'package:secret_vault_app/shared/widgets/poster_image.dart';
import 'package:secret_vault_app/shared/widgets/rating_badge.dart';

class TvSeriesPage extends ConsumerStatefulWidget {
  const TvSeriesPage({super.key});

  @override
  ConsumerState<TvSeriesPage> createState() => _TvSeriesPageState();
}

class _TvSeriesPageState extends ConsumerState<TvSeriesPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _tabCount = 1;

  static const _staticTabs = [
    ('Popular', 'popular'),
    ('Top Rated', 'top_rated'),
    ('Airing Today', 'airing_today'),
    ('On The Air', 'on_the_air'),
    ('Trending', 'trending'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabCount, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Safely recreates the TabController when the number of tabs changes.
  void _updateTabController(int newLength) {
    if (_tabCount != newLength) {
      _tabCount = newLength;
      final oldController = _tabController;
      _tabController = TabController(length: newLength, vsync: this);
      WidgetsBinding.instance.addPostFrameCallback((_) => oldController.dispose());
    }
  }

  @override
  Widget build(BuildContext context) {
    final genresAsync = ref.watch(tvGenresProvider);

    return genresAsync.when(
      loading: () => _buildScaffold(genres: []),
      error: (e, _) => _buildScaffold(genres: [], error: e.toString()),
      data: (genres) => _buildScaffold(genres: genres),
    );
  }

  Widget _buildScaffold({required List<Genre> genres, String? error}) {
    final tabs = [
      ..._staticTabs,
      ...genres.map((g) => (g.name, 'genre_${g.id}')),
    ];

    _updateTabController(tabs.isEmpty ? 1 : tabs.length);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        title:
            const Text('TV Series', style: TextStyle(color: AppTheme.onBackground)),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.onSurfaceVariant,
          indicatorColor: AppTheme.primary,
          tabAlignment: TabAlignment.start,
          tabs: tabs.map((t) => Tab(text: t.$1)).toList(),
        ),
      ),
      body: error != null
          ? ErrorView(message: error)
          : TabBarView(
              controller: _tabController,
              children: tabs.map((t) {
                final category =
                    t.$2.startsWith('genre_') ? 'genre' : t.$2;
                final genreId = t.$2.startsWith('genre_')
                    ? int.parse(t.$2.split('_')[1])
                    : null;
                return _TvListTab(category: category, genreId: genreId);
              }).toList(),
            ),
    );
  }
}

class _TvListTab extends ConsumerStatefulWidget {
  final String category;
  final int? genreId;

  const _TvListTab({required this.category, this.genreId});

  @override
  ConsumerState<_TvListTab> createState() => _TvListTabState();
}

class _TvListTabState extends ConsumerState<_TvListTab>
    with AutomaticKeepAliveClientMixin {
  late final StateNotifierProvider<TvListNotifier, TvListState> _provider;
  final _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

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
    super.build(context);
    final state = ref.watch(_provider);

    if (state.series.isEmpty && state.isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.primary));
    }

    if (state.series.isEmpty && state.error != null) {
      return ErrorView(
        message: state.error!,
        onRetry: () => ref.read(_provider.notifier).refresh(),
      );
    }

    return RefreshIndicator(
      color: AppTheme.primary,
      onRefresh: () => ref.read(_provider.notifier).refresh(),
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.55,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: state.series.length + (state.isLoading ? 2 : 0),
        itemBuilder: (context, i) {
          if (i >= state.series.length) {
            return const _ShimmerCard();
          }
          return _TvCard(series: state.series[i]);
        },
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
                                color: AppTheme.onSurfaceVariant, fontSize: 11)),
                      ],
                    ),
                    if (series.overview != null && series.overview!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(series.overview!,
                          style: const TextStyle(
                              color: AppTheme.onSurfaceVariant, fontSize: 11),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ],
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

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard();

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
