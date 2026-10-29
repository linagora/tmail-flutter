import 'package:get/get.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/jmap_request.dart';
import 'package:jmap_dart_client/jmap/mail/vacation/set/set_vacation_method.dart';
import 'package:jmap_dart_client/jmap/mail/vacation/set/set_vacation_response.dart';
import 'package:jmap_dart_client/jmap/mail/vacation/vacation_id.dart';
import 'package:jmap_dart_client/jmap/mail/vacation/vacation_response.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';

class VacationProvisioner {
  MailboxDashBoardController get _dashboard =>
      Get.find<MailboxDashBoardController>();

  Future<void> provision(VacationResponse vacation) async {
    final vacationId = VacationId.singleton().id;
    final method = SetVacationMethod(_dashboard.accountId.value!)
      ..addUpdatesSingleton({vacationId: vacation});
    final requestBuilder = JmapRequestBuilder(
      Get.find<HttpClient>(),
      ProcessingInvocation(),
    );
    final invocation = requestBuilder.invocation(method);
    final response = await (requestBuilder..usings(method.requiredCapabilities))
        .build()
        .execute();
    final setResponse = response.parse<SetVacationResponse>(
      invocation.methodCallId,
      SetVacationResponse.deserialize,
    );
    if (setResponse?.updated?.containsKey(vacationId) != true) {
      throw StateError('provisioning failed: ${setResponse?.notUpdated}');
    }
  }
}
