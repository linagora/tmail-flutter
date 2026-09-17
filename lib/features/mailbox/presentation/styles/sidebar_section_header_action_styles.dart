import 'package:core/utils/platform_info.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';

class SidebarSectionHeaderActionStyles {
  SidebarSectionHeaderActionStyles._();

  /// Gap the touch design puts between the actions of a `Navigation Section Header`.
  static const double touchActionSpacing = 12;

  /// Pointer platforms keep the header's own gap.
  static double get actionSpacing => PlatformInfo.isTouchPlatform
      ? touchActionSpacing
      : LinagoraSidebarSectionHeader.actionSpacing;

  /// Touch sizes the glyph to the sidebar item icon; pointer keeps Figma's XSmall.
  static double resolveIconSize(LinagoraSidebarStyle style) =>
      PlatformInfo.isTouchPlatform
          ? style.itemIconSize
          : LinagoraSidebarSectionHeaderAction.size;
}
