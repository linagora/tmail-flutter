import 'package:core/utils/sentry/sentry_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/handle_preferences_setting_extension.dart';
import 'package:tmail_ui_user/features/server_settings/domain/usecases/get_server_setting_interactor.dart';

class _Dashboard extends Fake implements MailboxDashBoardController {
  _Dashboard(AccountId? shownAccountId) {
    accountId.value = shownAccountId;
  }

  @override
  final accountId = Rxn<AccountId>();

  @override
  GetServerSettingInteractor? getServerSettingInteractor;
}

void main() {
  setUp(() => SentryManager.instance.clearSessionContext());

  test('resolves the Sentry consent when the server has no settings capability',
      () {
    _Dashboard(AccountId(Id('alice'))).getServerSetting();

    expect(SentryManager.instance.isReportingConsentResolved, isTrue);
  });

  test('leaves the Sentry consent pending while no account is shown', () {
    _Dashboard(null).getServerSetting();

    expect(SentryManager.instance.isReportingConsentResolved, isFalse);
  });
}
