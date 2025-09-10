extension IterableExtension<T> on Iterable<T> {
  /// Group elements by [keySelector].
  /// If [sortKeys] = true, the keys will be sorted in ascending order,
  /// key == -1 will always be at the bottom (applies to int keys).
  Map<K, List<T>> groupBy<K>(
    K Function(T element) keySelector, {
    bool sortKeys = false,
  }) {
    final map = <K, List<T>>{};
    for (final element in this) {
      final key = keySelector(element);
      map.putIfAbsent(key, () => []).add(element);
    }

    Iterable<K> sortedKeys;

    if (sortKeys && K == int) {
      sortedKeys = map.keys.toList()
        ..sort((a, b) {
          final ai = a as int;
          final bi = b as int;
          if (ai == -1 && bi != -1) return 1;
          if (bi == -1 && ai != -1) return -1;
          return ai.compareTo(bi);
        });
    } else if (sortKeys) {
      sortedKeys = map.keys.toList()
        ..sort((a, b) {
          if (a is Comparable && b is Comparable) {
            return (a as Comparable).compareTo(b);
          }
          return 0;
        });
    } else {
      sortedKeys = map.keys;
    }

    final result = <K, List<T>>{};
    for (final key in sortedKeys) {
      result[key] = map[key]!;
    }
    return result;
  }
}
