import 'package:core/presentation/views/checkbox/custom_icon_labeled_checkbox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/quick_search_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/search_filters/search_filter_button.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_builder.dart'
    if (dart.library.html) 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_web_builder.dart';

import '../base/core_robot.dart';
import 'abstract/abstract_search_result_assertion_robot.dart';

/// Widget-property reads; hit-test-independent, so no platform override needed.
class SearchResultAssertionRobot extends CoreRobot
    implements AbstractSearchResultAssertionRobot {
  SearchResultAssertionRobot(super.$);

  @override
  Future<void> expectQuickSearchFilterSelected(QuickSearchFilter filter) async {
    final chip = $(Key('${UiKeys.quickSearchFilterButtonPrefix}${filter.name}'))
        .which<SearchFilterButton>((widget) => widget.isSelected);
    expect(chip.exists, isTrue);
  }

  @override
  Future<void> expectEmailSubjectNotPresent(String subject) async {
    final match = $(EmailTileBuilder).which<EmailTileBuilder>(
      (view) => view.presentationEmail.subject?.contains(subject) == true,
    );
    expect(match.exists, isFalse);
  }

  @override
  Future<void> expectAdvancedSearchHasAttachmentChecked() async {
    final checkbox =
        $(const ValueKey(UiKeys.advancedSearchHasAttachmentCheckbox))
            .which<CustomIconLabeledCheckbox>((widget) => widget.value);
    expect(checkbox.exists, isTrue);
  }
}
