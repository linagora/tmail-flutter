import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/manage_account_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_label_setting_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_label_setting_state_interactor.dart';

import '../../../../fixtures/delegation_fixtures.dart';
import 'get_label_setting_state_interactor_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ManageAccountRepository>()])
void main() {
  late MockManageAccountRepository repository;
  late GetLabelSettingStateInteractor interactor;

  setUp(() {
    repository = MockManageAccountRepository();
    interactor = GetLabelSettingStateInteractor(repository);
  });

  test('the label setting is tagged with the account it was read for', () async {
    when(repository.getLabelSettingState()).thenAnswer((_) async => true);

    final states = await interactor.execute(DelegationFixtures.bobAccountId).toList();

    expect(states.last, Right(GetLabelSettingStateSuccess(true, DelegationFixtures.bobAccountId)));
  });

  test('a failed label setting read is tagged with the account it was read for', () async {
    final exception = Exception('read');
    when(repository.getLabelSettingState()).thenThrow(exception);

    final states = await interactor.execute(DelegationFixtures.bobAccountId).toList();

    expect(states.last, Left(GetLabelSettingStateFailure(exception, DelegationFixtures.bobAccountId)));
    expect(
      states.last,
      isNot(Left(GetLabelSettingStateFailure(exception, DelegationFixtures.aliceAccountId))),
    );
  });
}
