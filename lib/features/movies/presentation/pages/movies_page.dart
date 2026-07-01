import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:secret_vault_app/core/routing/app_router.dart';
import 'package:secret_vault_app/core/theme/app_theme.dart';
import 'package:secret_vault_app/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:secret_vault_app/features/movies/domain/entities/movie.dart';
import 'package:secret_vault_app/features/movies/presentation/providers/movie_providers.dart';
import 'package:secret_vault_app/shared/models/genre.dart';
import 'package:secret_vault_app/shared/widgets/error_view.dart';
import 'package:secret_vault_app/shared/widgets/poster_image.dart';
import 'package:secret_vault_app/shared/widgets/rating_badge.dart';

class MoviesPage extends ConsumerStatefulWidget {
  const MoviesPage({super.key});

  @override
  ConsumerState<MoviesPage> createState() => _MoviesPageState();
}

class _MoviesPageState extends ConsumerState<MoviesPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _tabCount = 1;

  static const _staticTabs = [
    ('Popular', 'popular'),
    ('Top Rated', 'top_rated'),
    ('Now Playing', 'now_playing'),
    ('Upcoming', 'upcoming'),
    ('Trending', 'trending'),
  ];

  // Country tabs: (display label, ISO 3166-1 alpha-2 code)
  // Add or remove entries here to customise which countries appear.
  static const _countryTabs = [
    ('🇺🇸 USA', 'US'),
    ('🇬🇧 UK', 'GB'),
    ('🇰🇷 Korean', 'KR'),
    ('🇯🇵 Japanese', 'JP'),
    ('🇮🇳 Indian', 'IN'),
    ('🇫🇷 French', 'FR'),
    ('🇩🇪 German', 'DE'),
    ('🇹🇭 Thai', 'TH'),
    ('🇨🇳 Chinese', 'CN'),
    ('🇪🇸 Spanish', 'ES'),
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
      // Defer disposal so the old controller is not used after disposal
      WidgetsBinding.instance.addPostFrameCallback((_) => oldController.dispose());
    }
  }

  @override
  Widget build(BuildContext context) {
    final genresAsync = ref.watch(movieGenresProvider);

    return genresAsync.when(
      loading: () => _buildScaffold(genres: []),
      error: (e, _) => _buildScaffold(genres: [], error: e.toString()),
      data: (genres) => _buildScaffold(genres: genres),
    );
  }

  Widget _buildScaffold({required List<Genre> genres, String? error}) {
    // Build a unified tab list: static → genre → country
    // Tab key encoding:
    //   'popular', 'top_rated', etc.  → static
    //   'genre_<id>'                  → genre
    //   'country_<code>'              → country (e.g. 'country_KR')
    final tabs = [
      ..._staticTabs,
      ...genres.map((g) => (g.name, 'genre_${g.id}')),
      ..._countryTabs.map((c) => (c.$1, 'country_${c.$2}')),
    ];

    _updateTabController(tabs.isEmpty ? 1 : tabs.length);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        title: const Text('Movies', style: TextStyle(color: AppTheme.onBackground)),
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
                if (t.$2.startsWith('genre_')) {
                  final genreId = int.parse(t.$2.split('_')[1]);
                  return _MovieListTab(category: 'genre', genreId: genreId);
                } else if (t.$2.startsWith('country_')) {
                  final code = t.$2.split('_')[1];
                  return _MovieListTab(category: 'country', countryCode: code);
                } else {
                  return _MovieListTab(category: t.$2);
                }
              }).toList(),
            ),
    );
  }
}

class _MovieListTab extends ConsumerStatefulWidget {
  final String category;
  final int? genreId;
  final String? countryCode;

  const _MovieListTab({
    required this.category,
    this.genreId,
    this.countryCode,
  });

  @override
  ConsumerState<_MovieListTab> createState() => _MovieListTabState();
}

class _MovieListTabState extends ConsumerState<_MovieListTab>
    with AutomaticKeepAliveClientMixin {
  late final StateNotifierProvider<MovieListNotifier, MovieListState> _provider;
  final _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _provider = movieListProvider(
      widget.category,
      genreId: widget.genreId,
      countryCode: widget.countryCode,
    );
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

    if (state.movies.isEmpty && state.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
    }

    if (state.movies.isEmpty && state.error != null) {
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
        itemCount: state.movies.length + (state.isLoading ? 2 : 0),
          itemBuilder: (context, i) {
          if (i >= state.movies.length) {
            return const _ShimmerCard();
          }
          return _MovieCard(movie: state.movies[i]);
        },
      ),
    );
  }
}

class _MovieCard extends ConsumerWidget {
  final Movie movie;

  const _MovieCard({required this.movie});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favNotifier = ref.read(favoritesProvider.notifier);
    final isFav = ref.watch(favoritesProvider
        .select((list) => list.any((f) => f.id == movie.id && f.isMovie)));

    return GestureDetector(
      onTap: () => context.push(AppRoutes.movieDetail(movie.id)),
      child: Card(
        color: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster
            Stack(
              children: [
                PosterImage(
                  imagePath: movie.posterPath,
                  height: 180,
                  width: double.infinity,
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () => favNotifier.toggleMovieFavorite(movie),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
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
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
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
                        RatingBadge(rating: movie.voteAverage, fontSize: 11),
                        const Spacer(),
                        Text(
                          movie.releaseYear,
                          style: const TextStyle(
                            color: AppTheme.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    if (movie.overview != null && movie.overview!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        movie.overview!,
                        style: const TextStyle(
                          color: AppTheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
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
            strokeWidth: 2,
            color: AppTheme.primary,
          ),
        ),
      ),
    );
  }
}
