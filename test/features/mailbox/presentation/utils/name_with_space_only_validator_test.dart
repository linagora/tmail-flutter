import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/name_with_space_only_validator.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/new_name_request.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/state/verify_name_view_state.dart';

void main() {
  group('NameWithSpaceOnlyValidator::validate::test', () {
    final validator = NameWithSpaceOnlyValidator();

    test('should return failure when name is spaces only', () {
      final result = validator.validate(NewNameRequest('   '));
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<VerifyNameFailure>()),
        (_) => fail('Expected a failure, but got a success.'),
      );
    });

    test('should return success when name is null', () {
      final result = validator.validate(NewNameRequest(null));
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected a success, but got a failure.'),
        (success) => expect(success, isA<VerifyNameViewState>()),
      );
    });

    test('should return success when name is empty', () {
      final result = validator.validate(NewNameRequest(''));
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected a success, but got a failure.'),
        (success) => expect(success, isA<VerifyNameViewState>()),
      );
    });

    test('should return success when name is valid', () {
      final result = validator.validate(NewNameRequest('validName'));
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected a success, but got a failure.'),
        (success) => expect(success, isA<VerifyNameViewState>()),
      );
    });
  });
}