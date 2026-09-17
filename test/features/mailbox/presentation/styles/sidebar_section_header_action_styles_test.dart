import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/styles/sidebar_section_header_action_styles.dart';

void main() {
  final style = LinagoraSidebarStyle.light();

  group('SidebarSectionHeaderActionStyles.resolveIconSize', () {
    test('uses the sidebar item icon size on a touch platform', () {
      final previousTargetPlatform = debugDefaultTargetPlatformOverride;
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      try {
        expect(
          SidebarSectionHeaderActionStyles.resolveIconSize(style),
          style.itemIconSize,
        );
      } finally {
        debugDefaultTargetPlatformOverride = previousTargetPlatform;
      }
    });

    test('uses the design XSmall dimension on a pointer platform', () {
      final previousTargetPlatform = debugDefaultTargetPlatformOverride;
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

      try {
        expect(
          SidebarSectionHeaderActionStyles.resolveIconSize(style),
          LinagoraSidebarSectionHeaderAction.size,
        );
      } finally {
        debugDefaultTargetPlatformOverride = previousTargetPlatform;
      }
    });
  });
}
