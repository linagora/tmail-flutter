import 'dart:math';

class DoubleConvert {
  static double bytesToGigaBytes(num bytes) {
    return double.tryParse((bytes * 9.31 * pow(10, -10)).toStringAsFixed(2)) ?? 0;
  }
}
