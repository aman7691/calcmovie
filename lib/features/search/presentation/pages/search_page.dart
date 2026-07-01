import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:secret_vault_app/core/routing/app_router.dart';
import 'package:secret_vault_app/core/theme/app_theme.dart';
import 'package:secret_vault_app/features/search/presentation/providers/search_provider.dart';
import 'package:secret_vault_app/shared/widgets/error_view.dart'
    show ErrorView, EmptyView;
import 'package:secret_vault_app/shared/widgets/poster_image.dart';
import 'package:secret_vault_app/shared/widgets/rating_badge.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    // 500ms debounce - avoids calling API on every keystroke
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(searchProvider.notifier).search(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        title: TextField(
          controller: _controller,
          onChanged: _onChanged,
          autofocus: false,
          style: const TextStyle(color: AppTheme.onBackground),
          decoration: InputDecoration(
            hintText: 'Search movies & TV series...',
            hintStyle: const TextStyle(color: AppTheme.onSurfaceVariant),
            border: InputBorder.none,
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear,
                        color: AppTheme.onSurfaceVariant),
                    onPressed: () {
                      _controller.clear();
                      ref.read(searchProvider.notifier).clear();
                    },
                  )
                : const Icon(Icons.search, color: AppTheme.onSurfaceVariant),
          ),
        ),
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(SearchState state) {
    if (state.query.isEmpty) {
      return const EmptyView(
        message: 'Search for movies and TV series',
        icon: Icons.search,
      );
    }

    if (state.isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.primary));
    }

    if (state.error != null) {
      return ErrorView(
        message: state.error!,
        onRetry: () =>
            ref.read(searchProvider.notifier).search(state.query),
      );
    }

    if (state.results.isEmpty) {
      return EmptyView(
        message: 'No results for "${state.query}"',
        icon: Icons.search_off,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: state.results.length,
      itemBuilder: (context, i) => _SearchResultTile(result: state.results[i]),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  final SearchResult result;
  const _SearchResultTile({required this.result});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      onTap: () {
        if (result.isMovie) {
          context.push(AppRoutes.movieDetail(result.id));
        } else {
          context.push(AppRoutes.tvDetail(result.id));
        }
      },
      leading: PosterImage(
        imagePath: result.posterPath,
        width: 50,
        height: 75,
        borderRadius: BorderRadius.circular(6),
      ),
      title: Text(
        result.title,
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
                  color: result.isMovie
                      ? AppTheme.primary.withValues(alpha: 0.2)
                      : Colors.teal.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  result.isMovie ? 'Movie' : 'TV Series',
                  style: TextStyle(
                    color: result.isMovie ? AppTheme.primary : Colors.teal,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (result.releaseYear != null)
                Text(result.releaseYear!,
                    style: const TextStyle(
                        color: AppTheme.onSurfaceVariant, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 4),
          RatingBadge(rating: result.voteAverage, fontSize: 12),
        ],
      ),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.onSurfaceVariant),
    );
  }
}
