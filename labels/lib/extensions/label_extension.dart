import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/extensions/hex_color_extension.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:labels/model/hex_color.dart';
import 'package:labels/model/label.dart';

extension LabelExtension on Label {
  static const String moreLabelId = 'more-btn';

  String get safeDisplayName => displayName ?? '';

  Color? get backgroundColor {
    if (id?.value == moreLabelId) {
      return AppColor.grayBackgroundColor;
    } else {
      return color?.value.toColor() ?? AppColor.primaryMain;
    }
  }

  Color get textColor {
    if (id?.value == moreLabelId) {
      return Colors.black;
    } else {
      return Colors.white;
    }
  }

  Label copyWith({
    Id? id,
    KeyWordIdentifier? keyword,
    String? displayName,
    HexColor? color,
  }) {
    return Label(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      keyword: keyword ?? this.keyword,
      color: color ?? this.color,
    );
  }

  int compareAlphabetically(Label otherLabel) {
    return safeDisplayName
        .toLowerCase()
        .compareTo(otherLabel.safeDisplayName.toLowerCase());
  }
}
