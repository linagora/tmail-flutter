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
}