import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/carry_over_composer_extension.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/delegation_ended_handler.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/open_and_close_composer_extension.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

/// Reopens every composer of the ended mailbox in the user's own one. Nothing is saved on the server.
class ComposerDelegationEndedHandler implements DelegationEndedHandler {
  const ComposerDelegationEndedHandler();

  @override
  Future<DelegationEndedHandling> beforeLeave() async {
    final dashboard = getBinding<MailboxDashBoardController>();
    if (dashboard == null) return const DelegationEndedHandling();

    final carried = <CarriedOverComposer>[];
    for (final composer in _openComposers(dashboard)) {
      try {
        carried.add(await composer.carryOverToAnotherAccount());
      } catch (error, stackTrace) {
        // This composer then closes like before and counts as lost.
        logError(
          'ComposerDelegationEndedHandler::beforeLeave: ${error.runtimeType}',
          exception: error,
          stackTrace: stackTrace,
        );
      }
    }
    if (carried.isEmpty) return const DelegationEndedHandling();

    return DelegationEndedHandling(
      keptComposerCount: carried.length,
      droppedAttachmentNames: [for (final composer in carried) ...composer.droppedAttachmentNames],
      afterLeave: () async {
        if (!PlatformInfo.isWeb) await _untilLeftComposerRouteIsGone();
        for (final composer in carried) {
          dashboard.openComposer(composer.arguments);
        }
      },
    );
  }

  static const _routeGonePoll = Duration(milliseconds: 50);
  static const _routeGoneTimeout = Duration(seconds: 2);

  /// The left route's controller is removed only when its pop animation ends, and a route pushed before would share it.
  Future<void> _untilLeftComposerRouteIsGone() async {
    var waited = Duration.zero;
    while (Get.isRegistered<ComposerController>() && waited < _routeGoneTimeout) {
      await Future.delayed(_routeGonePoll);
      waited += _routeGonePoll;
    }
  }

  /// A mobile composer is its own route, whose controller is registered without a tag while it is open.
  List<ComposerController> _openComposers(MailboxDashBoardController dashboard) => [
        for (final view in dashboard.composerManager.composers.values) view.controller,
        if (Get.isRegistered<ComposerController>()) Get.find<ComposerController>(),
      ];
}
