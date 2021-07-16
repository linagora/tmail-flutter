import 'package:model/model.dart';

extension UnsignedIntExtension on UnsignedInt {
  int compareToSort(UnsignedInt unsignedInt) => value.compareTo(unsignedInt.value);
}