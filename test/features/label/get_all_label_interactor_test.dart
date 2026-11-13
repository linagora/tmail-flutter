import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/labels/domain/repository/label_repository.dart';
import 'package:tmail_ui_user/features/labels/domain/state/get_all_label_state.dart';
import 'package:tmail_ui_user/features/labels/domain/usecases/get_all_label_interactor.dart';

import '../../fixtures/delegation_fixtures.dart';
import 'get_all_label_interactor_test.mocks.dart';

@GenerateNiceMocks([MockSpec<LabelRepository>()])
void main() {
  test('the labels are tagged with the account they were read from', () async {
    final repository = MockLabelRepository();
    final newState = jmap.State('delegated-state');
    when(repository.getAllLabels(DelegationFixtures.bobAccountId))
        .thenAnswer((_) async => (labels: const <Never>[], newState: newState));

    final result = await GetAllLabelInteractor(repository)
        .execute(DelegationFixtures.bobAccountId)
        .last;

    expect(result, Right(GetAllLabelSuccess(const [], newState, DelegationFixtures.bobAccountId)));
  });
}
