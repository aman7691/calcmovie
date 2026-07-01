import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:secret_vault_app/core/constants/app_constants.dart';
import 'package:secret_vault_app/features/favorites/data/models/favorite_item_model.dart';
import 'package:secret_vault_app/features/movies/domain/entities/movie.dart';
import 'package:secret_vault_app/features/tv_series/domain/entities/tv_series.dart';

/// Manages the local favorites stored in Hive.
/// Persists across app restarts automatically via Hive.
class FavoritesNotifier extends StateNotifier<List<FavoriteItemModel>> {
  final Box<FavoriteItemModel> _box;

  FavoritesNotifier(this._box) : super(_box.values.toList());

  /// Unique key for storing each favorite (avoids movie/TV ID collision)
  String _key(int id, bool isMovie) => '${isMovie ? "m" : "t"}_$id';

  bool isFavorite(int id, bool isMovie) =>
      _box.containsKey(_key(id, isMovie));

  void addMovieFavorite(Movie movie) {
    final item = FavoriteItemModel(
      id: movie.id,
      title: movie.title,
      posterPath: movie.posterPath,
      voteAverage: movie.voteAverage,
      releaseDate: movie.releaseDate,
      overview: movie.overview,
      isMovie: true,
      backdropPath: movie.backdropPath,
    );
    _box.put(_key(movie.id, true), item);
    state = _box.values.toList();
  }

  void addTvFavorite(TvSeries series) {
    final item = FavoriteItemModel(
      id: series.id,
      title: series.name,
      posterPath: series.posterPath,
      voteAverage: series.voteAverage,
      releaseDate: series.firstAirDate,
      overview: series.overview,
      isMovie: false,
      backdropPath: series.backdropPath,
    );
    _box.put(_key(series.id, false), item);
    state = _box.values.toList();
  }

  void removeFavorite(int id, bool isMovie) {
    _box.delete(_key(id, isMovie));
    state = _box.values.toList();
  }

  void toggleMovieFavorite(Movie movie) {
    if (isFavorite(movie.id, true)) {
      removeFavorite(movie.id, true);
    } else {
      addMovieFavorite(movie);
    }
  }

  void toggleTvFavorite(TvSeries series) {
    if (isFavorite(series.id, false)) {
      removeFavorite(series.id, false);
    } else {
      addTvFavorite(series);
    }
  }

  /// Remove by id and type — used from favorites list page
  void removeById(int id, bool isMovie) => removeFavorite(id, isMovie);

  /// Clear all favorites
  void clearAll() {
    _box.clear();
    state = [];
  }
}

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, List<FavoriteItemModel>>(
  (ref) {
    final box = Hive.box<FavoriteItemModel>(AppConstants.favoritesBoxName);
    return FavoritesNotifier(box);
  },
);
