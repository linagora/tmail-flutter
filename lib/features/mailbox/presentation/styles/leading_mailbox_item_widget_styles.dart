
import 'package:core/utils/direction_utils.dart';
import 'package:flutter/material.dart';

class LeadingMailboxItemWidgetStyles {
  static Matrix4 mailboxIconTransform(BuildContext context) => Matrix4.translationValues(
    DirectionUtils.isDirectionRTLByLanguage(context) ? 0.0 : -4.0,
    0.0,
    0.0
  );
}