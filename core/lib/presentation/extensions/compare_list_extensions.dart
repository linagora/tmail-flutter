
import 'package:collection/collection.dart';

extension CompareListExtension on List {
  bool isSame(List value) {
    Function unOrdDeepEq = const DeepCollectionEquality.unordered().equals;
    return unOrdDeepEq(this, value);
  }
}