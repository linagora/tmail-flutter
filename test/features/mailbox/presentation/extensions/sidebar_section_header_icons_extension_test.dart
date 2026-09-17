import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/sidebar_section_header_icons_extension.dart';

void main() {
  final imagePaths = ImagePaths();

  group('SidebarSectionHeaderIconsExtension', () {
    test('resolves the borderless glyphs on a touch platform', () {
      final previousTargetPlatform = debugDefaultTargetPlatformOverride;
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      try {
        expect(imagePaths.sidebarSearchIcon, imagePaths.icMagnifierNoBorder);
        expect(imagePaths.sidebarAddIcon, imagePaths.icPlusNoBorder);
      } finally {
        debugDefaultTargetPlatformOverride = previousTargetPlatform;
      }
    });

    test('keeps the inset glyphs on a pointer platform', () {
      final previousTargetPlatform = debugDefaultTargetPlatformOverride;
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

      try {
        expect(imagePaths.sidebarSearchIcon, imagePaths.icSearchBar);
        expect(imagePaths.sidebarAddIcon, imagePaths.icAddNewFolder);
      } finally {
        debugDefaultTargetPlatformOverride = previousTargetPlatform;
      }
    });
  });
}
