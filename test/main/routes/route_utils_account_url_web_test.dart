@TestOn('chrome')

import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/navigation_router.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';

import '../../fixtures/active_account_source_fixtures.dart';
import '../../fixtures/delegation_fixtures.dart';

void main() {
  final folderRouter = NavigationRouter(mailboxId: MailboxId(Id('folder-id')));

  tearDown(ActiveAccountSourceFixtures.unregister);

  void show(AccountId shownAccountId) => ActiveAccountSourceFixtures.put(
        DelegationFixtures.session(),
        shownAccountId: shownAccountId,
      );

  group('a web location bar URL while a delegated account is shown:', () {
    setUp(() => show(DelegationFixtures.bobAccountId));

    test('names it on a folder URL, and the start parses it back', () {
      final url = RouteUtils.createUrlWebLocationBar(AppRoutes.dashboard, router: folderRouter);

      expect(url.queryParameters[RouteUtils.paramAccount], DelegationFixtures.bobAccountId.id.value);
      expect(url.queryParameters[RouteUtils.paramContext], 'folder-id');
      expect(
        RouteUtils.parsingRouteParametersToNavigationRouter(url.queryParameters).accountId,
        DelegationFixtures.bobAccountId,
      );
    });

    test('names it on the dashboard URL without a router', () {
      final url = RouteUtils.createUrlWebLocationBar(AppRoutes.dashboard);

      expect(url.queryParameters, {
        RouteUtils.paramType: DashboardType.normal.name,
        RouteUtils.paramAccount: DelegationFixtures.bobAccountId.id.value,
      });
    });

    test('names it on an .eml previewer URL', () {
      final url = RouteUtils.createUrlWebLocationBar(AppRoutes.emailEMLPreviewer, previewId: 'preview-id');

      expect(url.queryParameters, {
        RouteUtils.paramID: 'preview-id',
        RouteUtils.paramAccount: DelegationFixtures.bobAccountId.id.value,
      });
    });

    test('should not add a query to an .eml previewer URL without a preview id', () {
      final url = RouteUtils.createUrlWebLocationBar(AppRoutes.emailEMLPreviewer);

      expect(url.queryParameters, isEmpty);
    });

    test('should not name it on a settings URL', () {
      final url = RouteUtils.createUrlWebLocationBar(AppRoutes.settings);

      expect(url.queryParameters.containsKey(RouteUtils.paramAccount), isFalse);
    });
  });

  test('a web location bar URL while my account is shown should not name an account', () {
    show(DelegationFixtures.aliceAccountId);

    final url = RouteUtils.createUrlWebLocationBar(AppRoutes.dashboard, router: folderRouter);

    expect(url.queryParameters.containsKey(RouteUtils.paramAccount), isFalse);
    expect(url.queryParameters[RouteUtils.paramContext], 'folder-id');
  });
}
