import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/manage_account_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/experimental_mode_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_experimental_mode_enabled_interactor.dart';

import 'get_experimental_mode_enabled_interactor_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ManageAccountRepository>()])
void main() {
  late MockManageAccountRepository mockRepo;
  late GetExperimentalModeEnabledInteractor interactor;

  setUp(() {
    mockRepo = MockManageAccountRepository();
    interactor = GetExperimentalModeEnabledInteractor(mockRepo);
  });

  group('GetExperimentalModeEnabledInteractor', () {
    test('returns Right with isEnabled=true when repo returns true', () async {
      when(mockRepo.getExperimentalModeEnabled()).thenAnswer((_) async => true);

      final result = await interactor.execute();

      result.fold(
        (_) => fail('expected Right'),
        (success) {
          expect(success, isA<GetExperimentalModeEnabledSuccess>());
          expect((success as GetExperimentalModeEnabledSuccess).isEnabled, isTrue);
        },
      );
    });

    test('returns Right with isEnabled=false when repo returns false', () async {
      when(mockRepo.getExperimentalModeEnabled()).thenAnswer((_) async => false);

      final result = await interactor.execute();

      result.fold(
        (_) => fail('expected Right'),
        (success) {
          expect(success, isA<GetExperimentalModeEnabledSuccess>());
          expect((success as GetExperimentalModeEnabledSuccess).isEnabled, isFalse);
        },
      );
    });

    test('returns Left(GetExperimentalModeEnabledFailure) when repo throws', () async {
      when(mockRepo.getExperimentalModeEnabled()).thenThrow(Exception('storage error'));

      final result = await interactor.execute();

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<GetExperimentalModeEnabledFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });
}
