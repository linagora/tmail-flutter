import 'package:core/presentation/extensions/string_extension.dart';
import 'package:core/presentation/views/image/avatar_builder.dart';
import 'package:flutter/material.dart';

/// Round initials avatar sized for the account switcher chip or menu tile.
Widget accountSwitcherAvatar(String emailAddress, double size) {
  // AvatarBuilder always wraps an InkWell that would swallow taps meant for the chip or tile.
  return IgnorePointer(
    child: (AvatarBuilder()
          ..text(emailAddress.firstCharacterToUpperCase)
          ..size(size)
          ..avatarColor(emailAddress.gradientColors)
          ..addTextStyle(TextStyle(
            color: Colors.white,
            fontSize: size * 0.44,
            fontWeight: FontWeight.w600,
          )))
        .build(),
  );
}
