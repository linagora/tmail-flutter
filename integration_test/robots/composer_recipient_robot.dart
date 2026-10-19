import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:patrol/patrol.dart';
import 'package:super_tag_editor/tag_editor.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/suggestion_email_address.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/recipient_composer_widget_style.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/recipient_tag_item_widget_style.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/recipient_composer_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/recipient_tag_item_widget.dart';

import '../base/core_robot.dart';
import '../extensions/patrol_finder_extension.dart';
import 'abstract/abstract_composer_recipient_assertion_robot.dart';
import 'abstract/abstract_composer_recipient_robot.dart';
import 'composer_recipient_assertion_robot.dart';

class ComposerRecipientRobot extends CoreRobot
    implements AbstractComposerRecipientRobot {
  static const _maxChips = 20;
  // Short, so the narrowest chip leaves a wide range of reachable widths.
  static const _domain = '@x.io';
  // Kept under the chip's 267 px max width, so its label never ellipsizes.
  static const _maxChipWidth = 250.0;

  @override
  final AbstractComposerRecipientAssertionRobot assertion;

  ComposerRecipientRobot(
    PatrolIntegrationTester $, {
    AbstractComposerRecipientAssertionRobot? assertionRobot,
  })  : assertion = assertionRobot ?? ComposerRecipientAssertionRobot($),
        super($);

  PatrolFinder _field(PrefixEmailAddress prefix) => $(RecipientComposerWidget)
      .which<RecipientComposerWidget>((widget) => widget.prefix == prefix);

  PatrolFinder _chips(PrefixEmailAddress prefix) =>
      _field(prefix).$(RecipientTagItemWidget);

  @override
  Future<void> openCcField() async {
    await $(Key('prefix_${PrefixEmailAddress.to.name}${UiKeys.recipientExpandButtonSuffix}')).tap();
  }

  @override
  Future<void> enterRecipient(PrefixEmailAddress prefix, String email) async {
    await _field(prefix).enterTextWithoutTapAction(email);
    await $.tester.testTextInput.receiveAction(TextInputAction.done);
    await $.pumpAndTrySettle();
  }

  @override
  Future<void> enterRecipientsUntilLineGap(
    PrefixEmailAddress prefix, {
    required double minGap,
    required double maxGap,
  }) async {
    await enterRecipient(prefix, 'filler$_domain');
    for (var index = 0; index < _maxChips; index++) {
      final gap = _lineGap(prefix);
      if (gap >= minGap && gap < maxGap) return;
      final chipWidth = _nextChipWidth(prefix, gap, (minGap + maxGap) / 2);
      await enterRecipient(prefix, _addressForChipWidth(prefix, index, chipWidth));
    }
    throw StateError('No $minGap-$maxGap px gap after the ${prefix.name} chips');
  }

  @override
  Future<void> tapRecipientInput(PrefixEmailAddress prefix) async {
    await _field(prefix).$(TextField).tap();
  }

  /// Free width after the last chip, up to the end of its line.
  double _lineGap(PrefixEmailAddress prefix) {
    final editor = _field(prefix).$(TagEditor<SuggestionEmailAddress>);
    return $.tester.getRect(editor).right - $.tester.getRect(_chips(prefix).last).right;
  }

  /// Width of the next chip: one that leaves [targetGap] after it when it
  /// can, else one that still leaves room for such a chip, else one too wide
  /// for this line so the next line starts.
  double _nextChipWidth(PrefixEmailAddress prefix, double gap, double targetGap) {
    const spacing = RecipientComposerWidgetStyle.tagSpacing;
    final minChipWidth = _chipWidth(prefix, '00$_domain');
    final room = gap - spacing;
    final finishing = room - targetGap;
    if (finishing >= minChipWidth && finishing <= _maxChipWidth) return finishing;
    final finishingLater = room - spacing - (minChipWidth + _maxChipWidth) / 2 - targetGap;
    if (finishing > _maxChipWidth) return max(minChipWidth, min(_maxChipWidth, finishingLater));
    return _maxChipWidth;
  }

  String _addressForChipWidth(PrefixEmailAddress prefix, int index, double width) {
    var localPart = '$index';
    while (_chipWidth(prefix, '${localPart}a$_domain') <= width) {
      localPart += 'a';
    }
    return '$localPart$_domain';
  }

  /// Predicted width of a chip labelled [email], from the last chip's padding
  /// and icons plus the label text width.
  double _chipWidth(PrefixEmailAddress prefix, String email) {
    final lastChip = _chips(prefix).last;
    final lastEmail = $.tester.widget<RecipientTagItemWidget>(lastChip)
        .currentEmailAddress
        .emailAddress;
    final chrome = $.tester.getSize(lastChip).width - _labelWidth(lastEmail);
    return chrome + _labelWidth(email);
  }

  double _labelWidth(String text) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: RecipientTagItemWidgetStyle.labelTextStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    final width = painter.width;
    painter.dispose();
    return width;
  }
}
