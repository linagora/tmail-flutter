import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/contact/presentation/contact_bindings.dart';
import 'package:tmail_ui_user/features/contact/presentation/contact_view.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/destination_picker_bindings.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/destination_picker_view.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/email_recovery_bindings.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/email_recovery_view.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/identity_creator_bindings.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/identity_creator_view.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/mailbox_creator_bindings.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/mailbox_creator_view.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/rules_filter_creator_bindings.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/rules_filter_creator_view.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';

class DialogRouter {
  static final _instance = DialogRouter._();

  factory DialogRouter() => _instance;

  DialogRouter._();
  
  Future<dynamic> pushGeneralDialog({
    required String routeName,
    required Object? arguments
  }) async {
    if (PlatformInfo.isWeb) {
      _isMapDialogOpened[routeName] = true;
    }
    _bindingDI(routeName);

    final returnedValue = await Get.generalDialog(
      barrierDismissible: true,
      barrierLabel: routeName,
      routeSettings: RouteSettings(arguments: arguments),
      pageBuilder: (_, __, ___) => _generateView(routeName: routeName)
    );

    if (PlatformInfo.isWeb) {
      _isMapDialogOpened[routeName] = false;
    }
    return returnedValue;
  }

  final RxMap<String, bool> _isMapDialogOpened = RxMap<String, bool>();

  bool get isDialogOpened =>
      _isMapDialogOpened.values.any((isOpened) => isOpened == true);

  void _bindingDI(String routeName) {
    log('DialogRouter::_bindingDI():routeName: $routeName');
    switch(routeName) {
      case AppRoutes.mailboxCreator:
        MailboxCreatorBindings().dependencies();
        break;
      case AppRoutes.rulesFilterCreator:
        RulesFilterCreatorBindings().dependencies();
        break;
      case AppRoutes.identityCreator:
        IdentityCreatorBindings().dependencies();
        break;
      case AppRoutes.destinationPicker:
        DestinationPickerBindings().dependencies();
        break;
      case AppRoutes.contact:
        ContactBindings().dependencies();
        break;
      case AppRoutes.emailRecovery:
        EmailRecoveryBindings().dependencies();
        break;
    }
  }

  Widget _generateView({required String routeName}) {
    switch(routeName) {
      case AppRoutes.mailboxCreator:
        return MailboxCreatorView();
      case AppRoutes.rulesFilterCreator:
        return RuleFilterCreatorView();
      case AppRoutes.identityCreator:
        return IdentityCreatorView();
      case AppRoutes.destinationPicker:
        return DestinationPickerView();
      case AppRoutes.contact:
        return const ContactView();
      case AppRoutes.emailRecovery:
        return EmailRecoveryView();
      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> openDialogModal({
    required Widget child,
    required String dialogLabel,
  }) async {
    if (PlatformInfo.isWeb) {
      _isMapDialogOpened[dialogLabel] = true;
    }
    await Get.generalDialog(
      barrierDismissible: true,
      barrierLabel: dialogLabel,
      pageBuilder: (_, __, ___) => child,
    );
    if (PlatformInfo.isWeb) {
      _isMapDialogOpened[dialogLabel] = false;
    }
  }
}