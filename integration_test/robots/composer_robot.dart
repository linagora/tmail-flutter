import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:rich_text_composer/rich_text_composer.dart';
import 'package:tmail_ui_user/features/composer/presentation/view/mobile/mobile_editor_view.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/mobile/app_bar_composer_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/recipient_composer_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/recipient_suggestion_item_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/subject_composer_widget.dart';

import '../base/core_robot.dart';

class ComposerRobot extends CoreRobot {
  ComposerRobot(super.$);

  Future<void> addReceipient(String email) async {
    await $(RecipientComposerWidget)
      .which<RecipientComposerWidget>((widget) => widget.prefix == PrefixEmailAddress.to)
      .enterText(email);
    await $(RecipientSuggestionItemWidget)
      .which<RecipientSuggestionItemWidget>((widget) => widget.emailAddress.email?.contains(email) ?? false)
      .tap();
  }

  Future<void> addSubject(String subject) async {
    await $(SubjectComposerWidget).enterText(subject);
  }

  Future<void> addContent(String content) async {
    await $(MobileEditorView).$(HtmlEditor).tap();
    await $(MobileEditorView).$(HtmlEditor).enterText(content);
  }

  Future<void> sendEmail() async {
    await $(AppBarComposerWidget)
      .$(TMailButtonWidget)
      .which<TMailButtonWidget>((widget) => widget.icon == ImagePaths().icSendMobile)
      .tap();
  }

  Future<void> expectSendEmailSuccessToast() async {
    expect($('Message has been sent successfully'), findsOneWidget);
  }
}