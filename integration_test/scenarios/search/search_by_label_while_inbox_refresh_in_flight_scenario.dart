import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:labels/labels.dart';
import 'package:tmail_ui_user/features/email/presentation/action/email_ui_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/search/email/domain/model/search_email_result.dart';
import 'package:tmail_ui_user/features/search/email/domain/notifier/search_email_notifier.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_web_builder.dart';
import 'package:tmail_ui_user/main/providers/app_provider_container.dart';

import '../../base/base_test_scenario.dart';
import '../../mixin/provisioning_label_scenario_mixin.dart';
import '../../robots/abstract/abstract_search_robot.dart';
import '../../utils/test_timeouts.dart';
import '../../utils/wait_for_condition.dart';

/// Holds the answer of an inbox listing query until [release] runs, and slows
/// label searches, so a refresh started before the search always finishes while
/// the search is in flight.
class _InboxRefreshGate extends Interceptor {
  final _released = Completer<void>();
  bool holding = false;

  void release() {
    if (!_released.isCompleted) _released.complete();
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final body = jsonEncode(
      response.requestOptions.data,
      toEncodable: (object) => object.toString(),
    );
    final isEmailQuery = body.contains('Email/query');
    final isLabelSearch = isEmailQuery && body.contains('hasKeyword');
    final isInboxListing =
        isEmailQuery && body.contains('inMailbox') && !isLabelSearch;

    if (holding && isInboxListing) {
      _released.future.then((_) => handler.next(response));
    } else if (isLabelSearch) {
      Future.delayed(const Duration(seconds: 2), () => handler.next(response));
    } else {
      handler.next(response);
    }
  }
}

/// An email state change starts an inbox refresh, the user searches by label
/// before it answers, and the refresh finishes while the search is loading. The
/// search result must still be listed.
class SearchByLabelWhileInboxRefreshInFlightScenario extends BaseTestScenario
    with ProvisioningLabelScenarioMixin {
  const SearchByLabelWhileInboxRefreshInFlightScenario(super.$, super.robots);

  static const _searchLabel = 'search-label';

  @override
  Future<void> runTestLogic() async {
    const emailUser = String.fromEnvironment('BASIC_AUTH_EMAIL');

    final AbstractSearchRobot searchRobot = robots.searchRobot();
    final commonRobot = robots.commonRobot();
    final gate = _InboxRefreshGate();
    Get.find<Dio>().interceptors.add(gate);

    final labels = await provisionLabelsByDisplayNames([_searchLabel]);
    final searchLabel = labels.firstWhere(
      (label) => label.safeDisplayName == _searchLabel,
    );
    await commonRobot.provisionEmail(
      buildEmailsForLabel(label: searchLabel, toEmail: emailUser, count: 1),
      requestReadReceipt: false,
    );
    await waitForCondition(
      () async {
        await $.pump();
        return $(EmailTileBuilder).evaluate().isNotEmpty;
      },
      timeout: TestTimeouts.medium,
      reason: 'the inbox lists the provisioned email',
    );

    // The refresh starts now and its answer is held until the search loads.
    gate.holding = true;
    final searchSubscription = appProviderContainer
        .listen<AsyncValue<SearchEmailResult>>(searchEmailProvider, (_, next) {
          if (next.isLoading) {
            Future.delayed(const Duration(milliseconds: 300), gate.release);
          }
        });
    addTearDown(searchSubscription.close);
    Get.find<MailboxDashBoardController>().dispatchEmailUIAction(
      RefreshChangeEmailAction(
        newState: jmap.State(
          'refresh-${DateTime.now().millisecondsSinceEpoch}',
        ),
      ),
    );

    await searchRobot.openSearch();
    await searchRobot.searchByLabel(_searchLabel);
    await searchRobot.expectEmailWithSubjectVisible(_searchLabel);
  }
}
