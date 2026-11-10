import 'package:core/presentation/extensions/string_extension.dart';
import 'package:core/presentation/views/image/avatar_builder.dart';
import 'package:flutter/material.dart';

/// Round initials avatar sized for the account switcher chip or menu tile.
Widget accountSwitcherAvatar(String emailAddress, double size) {
  return (AvatarBuilder()
        ..text(emailAddress.firstCharacterToUpperCase)
        ..size(size)
        ..avatarColor(emailAddress.gradientColors)
        ..addTextStyle(TextStyle(
          color: Colors.white,
          fontSize: size * 0.44,
          fontWeight: FontWeight.w600,
        )))
      .build();
}
