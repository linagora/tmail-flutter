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
  Future<AfterDelegationLeft?> beforeLeave() async {
    final dashboard = getBinding<MailboxDashBoardController>();
    if (dashboard == null) return null;

    final carried = await _carryOver(dashboard);
    if (carried.isEmpty) return null;

    return (showsMine) => _reopen(dashboard, carried, showsMine);
  }

  Future<List<CarriedOverComposer>> _carryOver(MailboxDashBoardController dashboard) async {
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
    return carried;
  }

  Future<DelegationEndedHandling> _reopen(
    MailboxDashBoardController dashboard,
    List<CarriedOverComposer> carried,
    ShowsMine showsMine,
  ) async {
    if (!PlatformInfo.isWeb) await _untilLeftComposerRouteIsGone();
    final reopened = <CarriedOverComposer>[];
    for (final composer in carried) {
      // The user may switch mailbox or sign out while the left route closes.
      if (!showsMine()) break;
      dashboard.openComposer(composer.arguments);
      reopened.add(composer);
    }
    return DelegationEndedHandling(
      keptComposerCount: reopened.length,
      droppedAttachmentNames: [for (final composer in reopened) ...composer.droppedAttachmentNames],
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
