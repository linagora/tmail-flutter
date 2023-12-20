
import 'package:core/utils/app_logger.dart';
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

  static Future<dynamic> pushGeneralDialog({
    required String routeName,
    required Object? arguments
  }) {
    _bindingDI(routeName);

    return Get.generalDialog(
      routeSettings: RouteSettings(arguments: arguments),
      pageBuilder: (_, __, ___) => _generateView(routeName: routeName, arguments: arguments)
    );
  }

  static void _bindingDI(String routeName) {
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

  static Widget _generateView({required String routeName, required Object? arguments}) {
    log('DialogRouter::_generateView():routeName: $routeName | arguments: $arguments');
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
}