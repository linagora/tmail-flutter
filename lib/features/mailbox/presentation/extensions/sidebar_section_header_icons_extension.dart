import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/utils/platform_info.dart';

extension SidebarSectionHeaderIconsExtension on ImagePaths {
  /// Borderless glyphs fill the 16dp box the touch design asks for.
  String get sidebarSearchIcon =>
      PlatformInfo.isTouchPlatform ? icMagnifierNoBorder : icSearchBar;

  String get sidebarAddIcon =>
      PlatformInfo.isTouchPlatform ? icPlusNoBorder : icAddNewFolder;
}
