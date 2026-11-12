import 'package:flutter/foundation.dart';

// One print per line: the web console forwarder keeps only the first line of a message.
void printStackLines(String tag, {int maxLines = 60}) {
  final lines = StackTrace.current
      .toString()
      .split('\n')
      .where((line) => line.trim().isNotEmpty)
      .take(maxLines);
  for (final line in lines) {
    debugPrintSynchronously('$tag $line');
  }
}
