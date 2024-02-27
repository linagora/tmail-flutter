import 'package:dartz/dartz.dart';

mixin OptionParamMixin {
  T? getOptionParam<T>(Option<T?>? option, T? defaultValue) {
    if (option != null) {
      return option.toNullable();
    } else {
      return defaultValue;
    }
  }
}