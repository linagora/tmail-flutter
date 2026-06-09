import 'package:core/presentation/views/checkbox/custom_icon_labeled_checkbox.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/base/model/filter_filter.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/base/widget/default_field/default_autocomplete_tag_item_widget.dart';
import 'package:tmail_ui_user/features/base/widget/default_field/default_date_drop_down_button.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/advanced_search/advanced_search_field_widget.dart';

import '../../base/core_robot.dart';
import '../../utils/wait_for_condition.dart';
import '../abstract/abstract_advanced_search_robot.dart';

class WebAdvancedSearchRobot extends CoreRobot implements AbstractAdvancedSearchRobot {
  WebAdvancedSearchRobot(super.$);

  @override
  Future<void> closeAdvancedSearch() async {
    await $(const ValueKey(UiKeys.advancedSearchCloseOverlay)).tap(alignment: Alignment.topLeft);
  }

  @override
  Future<void> tapSearchButton() async {
    await $(const ValueKey(UiKeys.advancedSearchSearchButton)).tap();
    await $.pump(const Duration(seconds: 2));
  }

  @override
  Future<void> expectHasAttachmentChecked(bool checked) async {
    expect(
      $(const ValueKey(UiKeys.advancedSearchHasAttachmentCheckbox))
        .which<CustomIconLabeledCheckbox>((w) => w.value == checked)
        .visible,
      true,
    );
  }

  @override
  Future<void> enterFromEmail(String email) async {
    final fromField = $(const ValueKey(UiKeys.advancedSearchFromEmailField)).$(TextField);
    await fromField.tap();
    await fromField.enterText(email);
    await $.tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await fromField.tap();
  }

  @override
  Future<void> expectFromFieldContains(String email) async {
    await $.waitUntilVisible(
      $(DefaultAutocompleteTagItemWidget)
        .which<DefaultAutocompleteTagItemWidget>(
          (w) => w.currentEmailAddress.email == email,
        ),
    );
  }

  @override
  Future<void> removeFromEmailTag(String email) async {
    final tagItem = $(DefaultAutocompleteTagItemWidget)
      .which<DefaultAutocompleteTagItemWidget>(
        (w) => w.currentEmailAddress.email == email,
      );
    await $.waitUntilVisible(tagItem);
    // AvatarTagItemWidget uses only Text — sole SvgPicture inside the chip is the delete icon
    await tagItem.$(find.byType(SvgPicture)).tap();
  }

  @override
  Future<void> expectFromFieldEmpty() async {
    await waitForCondition(
      () => $(DefaultAutocompleteTagItemWidget).evaluate().isEmpty,
    );
  }

  @override
  Future<void> expectReceiveTimeSelected(EmailReceiveTimeType receiveTimeType) async {
    await $.waitUntilExists(
      $(DateDropDownButton)
        .which<DateDropDownButton>((w) => w.receiveTimeTypeSelected == receiveTimeType),
    );
  }

  @override
  Future<void> focusField(FilterField filterField) async {
    await $(AdvancedSearchFieldWidget)
        .which<AdvancedSearchFieldWidget>((w) => w.filterField == filterField)
        .$(TextField)
        .tap();
  }
}
