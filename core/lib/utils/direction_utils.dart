
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

abstract class DirectionUtils {

  static bool isDirectionRTLByLanguage(BuildContext context) => intl.Bidi.isRtlLanguage(Localizations.localeOf(context).languageCode);

  static bool isDirectionRTLByEndsText(String text) => intl.Bidi.endsWithRtl(text);

  static bool isDirectionRTLByHasAnyRtl(String text) => intl.Bidi.hasAnyRtl(text);

  static TextDirection getDirectionByLanguage(BuildContext context) => isDirectionRTLByLanguage(context) ? TextDirection.rtl : TextDirection.ltr;

  static TextDirection getDirectionByEndsText(String text) => isDirectionRTLByEndsText(text) ? TextDirection.rtl : TextDirection.ltr;
}