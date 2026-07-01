import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:secret_vault_app/core/constants/app_constants.dart';
import 'package:secret_vault_app/features/history/data/models/watch_history_model.dart';
import 'package:secret_vault_app/features/movies/domain/entities/movie.dart';
import 'package:secret_vault_app/features/tv_series/domain/entities/tv_series.dart';

/// Maximum number of items to keep in watch history.
const int _kMaxHistory = 50;

/// Riverpod provider — exposes the sorted watch history list (most-recent first).
final watchHistoryProvider =
    StateNotifierProvider<WatchHistoryNotifier, List<WatchHistoryModel>>(
  (ref) => WatchHistoryNotifier(),
);

class WatchHistoryNotifier extends StateNotifier<List<WatchHistoryModel>> {
  WatchHistoryNotifier() : super([]) {
    _load();
  }

  Box<WatchHistoryModel> get _box =>
      Hive.box<WatchHistoryModel>(AppConstants.watchHistoryBoxName);

  // ── Load ─────────────────────────────────────────────────────────────────

  void _load() {
    final items = _box.values.toList()
      ..sort((a, b) => b.watchedAt.compareTo(a.watchedAt));
    state = items;
  }

  // ── Add / Update ──────────────────────────────────────────────────────────

  Future<void> addMovie(Movie movie) async {
    await _upsert(
      WatchHistoryModel(
        id: movie.id,
        title: movie.title,
        posterPath: movie.posterPath,
        isMovie: true,
        watchedAt: DateTime.now().toUtc().toIso8601String(),
        voteAverage: movie.voteAverage,
      ),
    );
  }

  Future<void> addTvSeries(TvSeries series) async {
    await _upsert(
      WatchHistoryModel(
        id: series.id,
        title: series.name,
        posterPath: series.posterPath,
        isMovie: false,
        watchedAt: DateTime.now().toUtc().toIso8601String(),
        voteAverage: series.voteAverage,
      ),
    );
  }

  // ── Remove ────────────────────────────────────────────────────────────────

  Future<void> remove(int id, bool isMovie) async {
    final key = _box.keys.firstWhere(
      (k) {
        final v = _box.get(k);
        return v != null && v.id == id && v.isMovie == isMovie;
      },
      orElse: () => null,
    );
    if (key != null) await _box.delete(key);
    _load();
  }

  Future<void> clearAll() async {
    await _box.clear();
    state = [];
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  Future<void> _upsert(WatchHistoryModel entry) async {
    // Remove existing entry for the same item so we don't get duplicates
    final existingKey = _box.keys.firstWhere(
      (k) {
        final v = _box.get(k);
        return v != null && v.id == entry.id && v.isMovie == entry.isMovie;
      },
      orElse: () => null,
    );
    if (existingKey != null) await _box.delete(existingKey);

    await _box.add(entry);

    // Trim to max size (keep most recent _kMaxHistory items)
    final all = _box.values.toList()
      ..sort((a, b) => b.watchedAt.compareTo(a.watchedAt));
    if (all.length > _kMaxHistory) {
      final toRemove = all.sublist(_kMaxHistory);
      for (final item in toRemove) {
        final k = _box.keys.firstWhere(
          (k) {
            final v = _box.get(k);
            return v != null &&
                v.id == item.id &&
                v.isMovie == item.isMovie &&
                v.watchedAt == item.watchedAt;
          },
          orElse: () => null,
        );
        if (k != null) await _box.delete(k);
      }
    }

    _load();
  }
}
