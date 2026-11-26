@TestOn('chrome')

import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/base/mixin/mailbox_action_handler_mixin.dart';
import 'package:tmail_ui_user/main/utils/app_route_tab_environment.dart';

class _RecordingTabEnvironment extends AppRouteTabEnvironment {
  final List<bool> isBasicAuthCalls = [];

  @override
  void openInNewTab(String url, {required bool isBasicAuth}) =>
      isBasicAuthCalls.add(isBasicAuth);
}

class _MailboxHost with MailboxActionHandlerMixin {
  _MailboxHost(this.isAuthenticatedWithOidc, this.tabEnvironment);

  @override
  final bool isAuthenticatedWithOidc;
  @override
  final AppRouteTabEnvironment tabEnvironment;
  @override
  AccountId? get activeAccountId => null;
}

void main() {
  final mailbox = PresentationMailbox(MailboxId(Id('folder-id')));

  for (final (isOidc, isBasicAuth) in [(false, true), (true, false)]) {
    test('openMailboxInNewTabAction: oidc=$isOidc opens with isBasicAuth=$isBasicAuth', () {
      final environment = _RecordingTabEnvironment();

      _MailboxHost(isOidc, environment).openMailboxInNewTabAction(mailbox);

      expect(environment.isBasicAuthCalls, [isBasicAuth]);
    });
  }
}
