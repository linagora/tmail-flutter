import 'dart:async';

import 'package:flutter/services.dart';

abstract class AppConfigParser<T> {
  Future<T> parse(String value);
  Future<T> parseData(ByteData data);
}