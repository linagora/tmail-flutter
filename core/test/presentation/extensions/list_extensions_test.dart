import 'package:core/presentation/extensions/list_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('list extensions test:', () {
    group('chunks test:', () {
      test('should return evenly sized chunks when length is divisible by chunkSize', () {
        // Arrange
        final sourceList = [1, 2, 3, 4, 5, 6];
        const chunkSize = 3;
        final expectedOutput = [
          [1, 2, 3],
          [4, 5, 6]
        ];

        // Act
        final result = sourceList.chunks(chunkSize);

        // Assert
        expect(result, equals(expectedOutput));
      });

      test('should return chunks with the last chunk smaller when length is not divisible', () {
        // Arrange
        final sourceList = [1, 2, 3, 4, 5];
        const chunkSize = 3;
        final expectedOutput = [
          [1, 2, 3],
          [4, 5]
        ];

        // Act
        final result = sourceList.chunks(chunkSize);

        // Assert
        expect(result, equals(expectedOutput));
      });

      test('should return chunks of size 1 when chunkSize is 1', () {
        // Arrange
        final sourceList = [1, 2, 3];
        const chunkSize = 1;
        final expectedOutput = [
          [1],
          [2],
          [3]
        ];

        // Act
        final result = sourceList.chunks(chunkSize);

        // Assert
        expect(result, equals(expectedOutput));
      });

      test('should return a single chunk when chunkSize equals list length', () {
        // Arrange
        final sourceList = [1, 2, 3, 4];
        const chunkSize = 4;
        final expectedOutput = [
          [1, 2, 3, 4]
        ];

        // Act
        final result = sourceList.chunks(chunkSize);

        // Assert
        expect(result, equals(expectedOutput));
      });

      test('should return a single chunk when chunkSize is greater than list length', () {
        // Arrange
        final sourceList = [1, 2, 3];
        const chunkSize = 5;
        final expectedOutput = [
          [1, 2, 3]
        ];

        // Act
        final result = sourceList.chunks(chunkSize);

        // Assert
        expect(result, equals(expectedOutput));
      });

      test('should return an empty list when the source list is empty', () {
        // Arrange
        final sourceList = <int>[]; // Explicitly typed empty list
        const chunkSize = 3;
        final expectedOutput = <List<int>>[]; // Expected empty list of lists

        // Act
        final result = sourceList.chunks(chunkSize);

        // Assert
        expect(result, isEmpty); // Check if it's empty
        expect(result, equals(expectedOutput)); // Also check for structural equality
      });

      test('should work with different list types (e.g., String)', () {
        // Arrange
        final sourceList = ['a', 'b', 'c', 'd', 'e'];
        const chunkSize = 2;
        final expectedOutput = [
          ['a', 'b'],
          ['c', 'd'],
          ['e']
        ];

        // Act
        final result = sourceList.chunks(chunkSize);

        // Assert
        expect(result, equals(expectedOutput));
      });

      test('should throw ArgumentError when chunkSize is 0', () {
        // Arrange
        final sourceList = [1, 2, 3];
        const chunkSize = 0;

        // Act & Assert
        // We wrap the call that is expected to throw in a zero-argument function.
        expect(() => sourceList.chunks(chunkSize), throwsArgumentError);
      });

      test('should throw ArgumentError when chunkSize is negative', () {
        // Arrange
        final sourceList = [1, 2, 3];
        const chunkSize = -1;

        // Act & Assert
        expect(() => sourceList.chunks(chunkSize), throwsArgumentError);
      });
    });
  });
}