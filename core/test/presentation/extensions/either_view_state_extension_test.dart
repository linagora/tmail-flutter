import 'package:core/presentation/extensions/either_view_state_extension.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';

class MockFailure extends Failure {
  final String message;

  MockFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class MockSuccess extends Success {
  final String data;

  MockSuccess(this.data);

  @override
  List<Object?> get props => [data];
}

class AnotherSuccess extends Success {
  @override
  List<Object?> get props => [];
}

void main() {
  group('EitherViewStateExtension::foldSuccess::test', () {
    test('Should calls onFailure when Either is Left', () {
      final either = Left<Failure, Success>(MockFailure('Error occurred'));
      bool failureCalled = false;

      either.foldSuccess<Success>(
        onSuccess: (_) => fail('onSuccess should not be called'),
        onFailure: (failure) {
          failureCalled = true;
          expect(failure, isNotNull);
          expect(failure, isA<MockFailure>());
        },
      );

      expect(failureCalled, isTrue);
    });

    test('Should calls onSuccess when Either is Right with matching type', () {
      final either = Right<Failure, Success>(MockSuccess('Successful'));
      bool successCalled = false;

      either.foldSuccess<Success>(
        onSuccess: (success) {
          successCalled = true;
          expect(success, isNotNull);
          expect(success, isA<MockSuccess>());
        },
        onFailure: (_) => fail('onFailure should not be called'),
      );

      expect(successCalled, isTrue);
    });

    test('Should calls onFailure when Either is Right with non-matching type', () {
      final either = Right<Failure, Success>(MockSuccess('Successful'));
      bool failureCalled = false;

      either.foldSuccess<AnotherSuccess>(
        onSuccess: (_) => fail('onSuccess should not be called'),
        onFailure: (failure) {
          failureCalled = true;
          expect(failure, isNull);
        },
      );

      expect(failureCalled, isTrue);
    });
  });
}
