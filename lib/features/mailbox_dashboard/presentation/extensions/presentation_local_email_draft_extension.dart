
import 'dart:ui';

import 'package:core/domain/extensions/datetime_extension.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/extensions/string_extension.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/presentation_local_email_draft.dart';

extension PresentationLocalEmailDraftExtension on PresentationLocalEmailDraft {

  String get avatarText {
    final recipientName = firstRecipientName;
    if (recipientName.isNotEmpty) {
      return recipientName.firstCharacterToUpperCase;
    }
    return '?';
  }

  List<Color> get avatarColors {
    if (email?.from?.isNotEmpty == true) {
      return email!.from!.first.avatarColors;
    } else {
      return AppColor.mapGradientColor.first;
    }
  }

  String get firstRecipientName {
    if (email?.to?.isNotEmpty == true) {
      return email!.to!.first.asString();
    } if (email?.cc?.isNotEmpty == true) {
      return email!.cc!.first.asString();
    } if (email?.bcc?.isNotEmpty == true) {
      return email!.bcc!.first.asString();
    } else {
      return senderName;
    }
  }

  String get senderName {
    if (email?.from?.isNotEmpty == true) {
      return email!.from!.first.asString();
    } else {
      return '';
    }
  }

  String get emailSubject => email?.subject?.trim() ?? '';

  String get emailContent {
    if (email?.bodyValues?.isNotEmpty == true) {
      return email?.bodyValues?.values.first.value ?? '';
    } else {
      return '';
    }
  }

  bool get hasAttachment => email?.attachments?.isNotEmpty == true;

  String getSavedTime(String locale) {
    return DateFormat(savedTime.toPattern(), locale).format(savedTime);
  }
}