import 'package:contact/contact/model/tmail_contact.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:model/autocomplete/auto_complete_pattern.dart';
import 'package:tmail_ui_user/features/contact/data/datasource_impl/tmail_contact_datasource_impl.dart';
import 'package:tmail_ui_user/features/contact/data/network/contact_api.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception_thrower.dart';

import 'tmail_contact_datasource_impl_test.mocks.dart';

@GenerateMocks([ContactAPI, RemoteExceptionThrower])
void main() {
  final contact1 = TMailContact(
    '2',
    '',
    '',
    'marie@otherdomain.tld',
  );

  final contact2 = TMailContact(
    '4',
    'Marie',
    'Dupond',
    'mdupond@linagora.com',
  );

  group('tmail_contact_datasource_impl_test', () {
    late ContactAPI contactAPI;
    late RemoteExceptionThrower exceptionThrower;
    late TMailContactDataSourceImpl tmailContactDataSourceImpl;

    setUp(() {
      contactAPI = MockContactAPI();
      exceptionThrower = MockRemoteExceptionThrower();
      tmailContactDataSourceImpl =
          TMailContactDataSourceImpl(contactAPI, exceptionThrower);
    });

    test('getAutoComplete should return success with valid data', () async {
      when(contactAPI.getAutoComplete(AutoCompletePattern(
        word: 'marie',
        accountId: AccountId(Id(
            '29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6')),
      ))).thenAnswer((_) async => [contact1, contact2]);

      final result =
          await tmailContactDataSourceImpl.getAutoComplete(AutoCompletePattern(
        word: 'marie',
        accountId: AccountId(Id(
            '29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6')),
      ));
      expect(result, [contact1.toEmailAddress(), contact2.toEmailAddress()]);
    });
  });
}
