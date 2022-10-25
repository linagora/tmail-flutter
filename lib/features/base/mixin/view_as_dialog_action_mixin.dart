
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/contact/presentation/contact_bindings.dart';
import 'package:tmail_ui_user/features/contact/presentation/contact_view.dart';
import 'package:tmail_ui_user/features/contact/presentation/model/contact_arguments.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/destination_picker_bindings.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/destination_picker_view.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/model/destination_picker_arguments.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/identity_creator_bindings.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/identity_creator_view.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/model/identity_creator_arguments.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/mailbox_creator_bindings.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/mailbox_creator_view.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/model/mailbox_creator_arguments.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/model/new_mailbox_arguments.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/rules_filter_creator_arguments.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/rules_filter_creator_bindings.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/rules_filter_creator_view.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

mixin ViewAsDialogActionMixin {

  void showDialogDestinationPicker({
    required BuildContext context,
    required DestinationPickerArguments arguments,
    required Function(PresentationMailbox) onSelectedMailbox
  }) {
    DestinationPickerBindings().dependencies();

    showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: '',
        barrierColor: Colors.black.withAlpha(24),
        pageBuilder: (context, animation, secondaryAnimation) {
          return DestinationPickerView.fromArguments(
              arguments,
              onDismissCallback: () {
                DestinationPickerBindings().dispose();
                popBack();
              },
              onSelectedMailboxCallback: (destinationMailbox) {
                DestinationPickerBindings().dispose();
                popBack();

                if (destinationMailbox is PresentationMailbox) {
                  onSelectedMailbox.call(destinationMailbox);
                }
              });
        });
  }

  void showDialogMailboxCreator({
    required BuildContext context,
    required MailboxCreatorArguments arguments,
    required Function(NewMailboxArguments) onCreatedMailbox
  }) {
    MailboxCreatorBindings().dependencies();

    showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: '',
        barrierColor: Colors.black.withAlpha(24),
        pageBuilder: (context, animation, secondaryAnimation) {
          return MailboxCreatorView.fromArguments(
              arguments,
              onDismissCallback: () {
                MailboxCreatorBindings().dispose();
                popBack();
              },
              onCreatedMailboxCallback: (arguments) {
                MailboxCreatorBindings().dispose();
                popBack();

                if (arguments is NewMailboxArguments) {
                  onCreatedMailbox.call(arguments);
                }
              });
        });
  }

  void showDialogContactView({
    required BuildContext context,
    required ContactArguments arguments,
    required Function(EmailAddress) onSelectedContact
  }) {
    ContactBindings().dependencies();

    showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: '',
        barrierColor: Colors.black.withAlpha(24),
        pageBuilder: (context, animation, secondaryAnimation) {
          return ContactView.fromArguments(
              arguments,
              onDismissCallback: () {
                ContactBindings().dispose();
                popBack();
              },
              onSelectedContactCallback: (emailAddress) {
                ContactBindings().dispose();
                popBack();

                onSelectedContact.call(emailAddress);
              });
        });
  }

  void showDialogIdentityCreator({
    required BuildContext context,
    required IdentityCreatorArguments arguments,
    required Function(dynamic) onCreatedIdentity
  }) {
    IdentityCreatorBindings().dependencies();

    showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: '',
        barrierColor: Colors.black.withAlpha(24),
        pageBuilder: (context, animation, secondaryAnimation) {
          return IdentityCreatorView.fromArguments(
              arguments,
              onDismissCallback: () {
                IdentityCreatorBindings().dispose();
                popBack();
              },
              onCreatedIdentityCallback: (args) {
                IdentityCreatorBindings().dispose();
                popBack();

                onCreatedIdentity.call(args);
              });
        });
  }

  void showDialogRuleFilterCreator({
    required BuildContext context,
    required RulesFilterCreatorArguments arguments,
    required Function(dynamic) onCreatedRuleFilter
  }) {
    RulesFilterCreatorBindings().dependencies();

    showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: '',
        barrierColor: Colors.black.withAlpha(24),
        pageBuilder: (context, animation, secondaryAnimation) {
          return RuleFilterCreatorView.fromArguments(
              arguments,
              onDismissCallback: () {
                RulesFilterCreatorBindings().dispose();
                popBack();
              },
              onCreatedRuleFilterCallback: (args) {
                RulesFilterCreatorBindings().dispose();
                popBack();

                onCreatedRuleFilter.call(args);
              });
        });
  }
}