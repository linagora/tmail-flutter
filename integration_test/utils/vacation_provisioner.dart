import 'package:jmap_dart_client/jmap/mail/vacation/set/set_vacation_method.dart';
import 'package:jmap_dart_client/jmap/mail/vacation/set/set_vacation_response.dart';
import 'package:jmap_dart_client/jmap/mail/vacation/vacation_id.dart';
import 'package:jmap_dart_client/jmap/mail/vacation/vacation_response.dart';

import 'jmap/jmap_test_client.dart';

class VacationProvisioner {
  Future<void> provision(VacationResponse vacation) async {
    final client = await JmapTestClient.current();
    final vacationId = VacationId.singleton().id;
    final response = await client.execute(
      SetVacationMethod(client.accountId)
        ..addUpdatesSingleton({vacationId: vacation}),
      SetVacationResponse.deserialize,
    );
    if (response.updated?.containsKey(vacationId) != true) {
      throw StateError('provisioning failed: ${response.notUpdated}');
    }
  }
}
