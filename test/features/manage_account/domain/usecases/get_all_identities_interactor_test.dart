import 'package:dartz/dartz.dart' hide State;
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/identities_response.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/identity_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_all_identities_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_identities_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/identities/utils/identity_utils.dart';

import '../../../../fixtures/account_fixtures.dart';
import '../../../../fixtures/session_fixtures.dart';
import 'get_all_identities_interactor_test.mocks.dart';

@GenerateNiceMocks([MockSpec<IdentityRepository>()])
void main() {
  final identityRepository = MockIdentityRepository();
  final getAllIdentitiesInteractor = GetAllIdentitiesInteractor(
    identityRepository,
    IdentityUtils());

  group('get all identities interactor test:', () {
    test(
      'should return only identities which name is not empty',
    () {
      // arrange
      final identity1 = Identity(name: '');
      final identity2 = Identity();
      final identity3 = Identity(name: 'valid name');
      final identity4 = Identity(name: '    ');
      when(identityRepository.getAllIdentities(any, any)).thenAnswer(
        (_) async => IdentitiesResponse(identities: [
          identity1,
          identity2,
          identity3,
          identity4
        ])        
      );
      
      // assert
      expect(
        getAllIdentitiesInteractor.execute(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId),
        emitsInOrder([
          Right(GetAllIdentitiesLoading()),
          Right(GetAllIdentitiesSuccess([identity3], null))
        ])
      );
    });
  });
}