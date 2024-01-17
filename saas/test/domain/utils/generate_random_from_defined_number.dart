import 'dart:math';

class GenerateRandomFromDefinedNumber implements Random {
  final List<int> definedNumbers;
  int currentIndex = 0;

  GenerateRandomFromDefinedNumber(this.definedNumbers) {
    currentIndex = 0;
  }

  @override
  bool nextBool() {
    final tempValue = definedNumbers[currentIndex++];
    if (tempValue == 0) {
      return false;
    } else {
      return true;
    }
  }

  @override
  double nextDouble() {
    if (currentIndex >= definedNumbers.length) {
      currentIndex = 0;
    }
    return definedNumbers[currentIndex++].toDouble();
  }

  @override
  int nextInt(int max) {
    if (currentIndex >= definedNumbers.length) {
      currentIndex = 0;
    }
    return definedNumbers[currentIndex++];
  }
}