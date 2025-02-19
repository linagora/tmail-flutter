
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dartz/dartz.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/composer/domain/state/save_email_as_drafts_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/send_email_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/update_email_drafts_state.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_bindings.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_view.dart';
import 'package:tmail_ui_user/features/email/presentation/action/email_ui_action.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/composer_arguments_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/sending_queue/presentation/model/sending_email_arguments.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension OpenAndCloseComposerExtension on MailboxDashBoardController {
  void openComposer(ComposerArguments arguments) {
    final argumentsWithIdentity = arguments.withIdentity(
      identities: List.from(listIdentities),
      selectedIdentityId: arguments.selectedIdentityId,
    );

    if (PlatformInfo.isWeb) {
      _openComposerOnWeb(argumentsWithIdentity);
    } else {
      _openComposerOnMobile(argumentsWithIdentity);
    }
  }

  void _openComposerOnWeb(ComposerArguments composerArguments) {
    composerManager.addComposer(composerArguments);
    if (!twakeAppManager.hasComposer) {
      twakeAppManager.setHasComposer(true);
    }
  }

  Future<void> _openComposerOnMobile(ComposerArguments arguments) async {
    BackButtonInterceptor.removeByName(AppRoutes.dashboard);

    bool isTabletPlatform = currentContext != null
        && !responsiveUtils.isScreenWithShortestSide(currentContext!);

    dynamic result;
    if (isTabletPlatform) {
      if (PlatformInfo.isIOS) {
        dispatchEmailUIAction(HideEmailContentViewAction());
      }

      result = await Get.to(
        () => const ComposerView(),
        binding: ComposerBindings(),
        opaque: false,
        arguments: arguments,
      );

      if (PlatformInfo.isIOS) {
        await Future.delayed(
          const Duration(milliseconds: 200),
          () => dispatchEmailUIAction(ShowEmailContentViewAction()),
        );
      }
    } else {
      result = await push(AppRoutes.composer, arguments: arguments);
    }

    BackButtonInterceptor.add(onBackButtonInterceptor, name: AppRoutes.dashboard);

    _handleResultAfterCloseComposer(result);
  }

  void closeComposer({
    dynamic result,
    bool closeOverlays = false,
    String? composerId,
  }) {
    if (PlatformInfo.isWeb) {
      if (closeOverlays) {
        popBack();
      }
      closeComposerOnWeb(composerId: composerId, result: result);
    } else {
      popBack(result: result, closeOverlays: closeOverlays);
    }
  }

  Future<void> closeComposerOnWeb({
    required String? composerId,
    dynamic result,
  }) async {
    if (composerId != null) {
      composerManager.removeComposer(composerId);
    }
    if (!composerManager.hasComposer) {
      twakeAppManager.setHasComposer(false);
    }

    _handleResultAfterCloseComposer(result);

    await removeComposerCacheOnWeb();
  }

  void _handleResultAfterCloseComposer(dynamic result) {
    if (result is SendingEmailArguments) {
      handleSendEmailAction(result);
    } else if (result is SendEmailSuccess ||
        result is SaveEmailAsDraftsSuccess ||
        result is UpdateEmailDraftsSuccess) {
      consumeState(Stream.value(Right(result)));
    } else if (validateSendingEmailFailedWhenNetworkIsLostOnMobile(result)) {
      storeSendingEmailInCaseOfSendingFailureInMobile(result);
    }
  }
}