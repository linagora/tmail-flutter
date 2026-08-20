import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/widgets.dart';

/// Whether the dedicated SearchEmailView owns the visible search results.
///
/// Web desktop renders search results in the thread list instead. A missing
/// context keeps SearchEmailView as the safe default while bindings initialize.
bool isSearchEmailPresentationLayoutOwner({
  required BuildContext? context,
  required ResponsiveUtils responsiveUtils,
}) => context == null || !responsiveUtils.isWebDesktop(context);
