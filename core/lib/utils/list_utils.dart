import 'package:dartz/dartz.dart';

Tuple2<List<T>, List<T>> partition<T>(List<T> list, bool Function(T) predicate) {
 List<T> trueList = [];
 List<T> falseList = [];

 for (var element in list) {
  if (predicate(element)) {
   trueList.add(element);
  } else {
   falseList.add(element);
  }
 }

 return Tuple2(trueList, falseList);
}