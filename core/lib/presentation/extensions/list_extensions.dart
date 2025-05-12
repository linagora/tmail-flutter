import 'package:built_collection/built_collection.dart';
import 'package:dartz/dartz.dart';

extension ListExtensions<T> on List<T> {
  Tuple2<List<T>, List<T>> split(bool Function(T element) test) {
    final validBuilder = ListBuilder<T>();
    final invalidBuilder = ListBuilder<T>();
    forEach((element) {
      if (test(element)) {
        validBuilder.add(element);
      } else {
        invalidBuilder.add(element);
      }
    });
    return Tuple2(
      validBuilder.build().toList(),
      validBuilder.build().toList());
  }

  int countOccurrences(T value) {
    return where((element) => element == value).length;
  }

  List<List<T>> chunks(int chunkSize) {
    if (chunkSize <= 0) {
      throw ArgumentError('Chunk size must be greater than 0', 'chunkSize');
    }
    if (isEmpty) {
      return [];
    }
    final result = <List<T>>[];
    final totalChunks = (length / chunkSize).ceil();
    for (var i = 0; i < totalChunks; i++) {
      final start = i * chunkSize;
      final end = (start + chunkSize).clamp(0, length);
      result.add(sublist(start, end));
    }
    return result;
  }
}