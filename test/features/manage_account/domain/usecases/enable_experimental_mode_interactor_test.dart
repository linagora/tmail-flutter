import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/manage_account_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/experimental_mode_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/enable_experimental_mode_interactor.dart';

import 'enable_experimental_mode_interactor_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ManageAccountRepository>()])
void main() {
  late MockManageAccountRepository mockRepo;
  late EnableExperimentalModeInteractor interactor;

  setUp(() {
    mockRepo = MockManageAccountRepository();
    interactor = EnableExperimentalModeInteractor(mockRepo);
  });

  group('EnableExperimentalModeInteractor', () {
    test('returns Right(EnableExperimentalModeSuccess) when repo completes', () async {
      when(mockRepo.enableExperimentalMode()).thenAnswer((_) async {});

      final result = await interactor.execute();

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('expected Right'),
        (success) => expect(success, isA<EnableExperimentalModeSuccess>()),
      );
    });

    test('returns Left(EnableExperimentalModeFailure) when repo throws', () async {
      when(mockRepo.enableExperimentalMode()).thenThrow(Exception('disk error'));

      final result = await interactor.execute();

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<EnableExperimentalModeFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });
}
