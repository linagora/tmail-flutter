import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/composer/domain/state/send_email_state.dart';
import 'package:tmail_ui_user/features/email/presentation/email_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_user_profile_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_user_profile_interactor.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class MailboxDashBoardController extends BaseController {

  final GetUserProfileInteractor _getUserProfileInteractor;
  final AppToast _appToast;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final selectedMailbox = Rxn<PresentationMailbox>();
  final selectedEmail = Rxn<PresentationEmail>();
  final accountId = Rxn<AccountId>();
  final userProfile = Rxn<UserProfile>();

  Session? sessionCurrent;
  Map<Role, MailboxId> mapMailboxId = Map();

  MailboxDashBoardController(this._getUserProfileInteractor, this._appToast);

  @override
  void onReady() {
    super.onReady();
    _setSessionCurrent();
    _getUserProfile();
  }

  @override
  void onData(Either<Failure, Success> newState) {
    super.onData(newState);
    viewState.value.map((success) {
      if (success is SendingEmailState) {
        if (Get.context != null) {
          _appToast.showToast(AppLocalizations.of(Get.context!).your_email_being_sent);
        }
      }
    });
  }

  @override
  void onDone() {
    viewState.value.fold(
      (failure) {
        if (failure is SendEmailFailure) {
          if (Get.context != null) {
            _appToast.showSuccessToast(AppLocalizations.of(Get.context!).error_message_sent);
            clearState();
          }
        }
      },
      (success) {
        if (success is GetUserProfileSuccess) {
          userProfile.value = success.userProfile;
        } else if (success is SendEmailSuccess) {
          if (Get.context != null) {
            _appToast.showSuccessToast(AppLocalizations.of(Get.context!).message_sent);
            clearState();
          }
        }
      }
    );
  }

  @override
  void onError(error) {
  }

  void _getUserProfile() async {
    consumeState(_getUserProfileInteractor.execute());
  }

  void _setSessionCurrent() {
    Future.delayed(const Duration(milliseconds: 100), () {
      final arguments = Get.arguments;
      if (arguments is Session) {
        sessionCurrent = Get.arguments as Session;
        accountId.value = sessionCurrent?.accounts.keys.first;
      }
    });
  }

  void setMapMailboxId(Map<Role, MailboxId> newMapMailboxId) {
    mapMailboxId = newMapMailboxId;
  }

  void setSelectedMailbox(PresentationMailbox? newPresentationMailbox) {
    selectedMailbox.value = newPresentationMailbox;
  }

  void setNewFirstSelectedMailbox(PresentationMailbox? newPresentationMailbox) {
    selectedMailbox.firstRebuild = true;
    selectedMailbox.value = newPresentationMailbox;
  }

  void setSelectedEmail(PresentationEmail? newPresentationEmail) {
    selectedEmail.value = newPresentationEmail;
  }

  void clearSelectedEmail() {
    selectedEmail.value = null;
  }

  void openDrawer() {
    scaffoldKey.currentState?.openDrawer();
  }

  void closeDrawer() {
    scaffoldKey.currentState?.openEndDrawer();
  }

  @override
  void onClose() {
    super.onClose();
    Get.delete<EmailController>();
  }
}