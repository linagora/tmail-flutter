import 'dart:ui' show Color;

import 'package:flutter/material.dart';

extension AppColor on Color {
  static const primaryColor = Color(0xFF007AFF);
  static const primaryDarkColor = Color(0xFF1C1C1C);
  static const primaryLightColor = Color(0xFFFFFFFF);
  static const baseTextColor = Color(0xFF7E869B);
  static const textFieldTextColor = Color(0xFF7E869B);
  static const textFieldLabelColor = Color(0xFF7E869B);
  static const textFieldHintColor = Color(0xFF757575);
  static const textFieldBorderColor = Color(0xfff2f3f5);
  static const textFieldFocusedBorderColor = Color(0xFF007AFF);
  static const loginTextFieldBorderColor = Color(0xFFF2F3F5);
  static const textFieldErrorBorderColor = Color(0xffE64646);
  static const loginTextFieldErrorBorder = Color(0xffE64646);
  static const loginTextFieldFocusedBorder = Color(0xFF007AFF);
  static const loginTextFieldHintColor = Color(0xff818C99);
  static const loginTextFieldBackgroundColor = Color(0xFFF2F3F5);
  static const loginTextFieldBackgroundErrorColor = Color(0xFFFAEBEB);
  static const buttonColor = Color(0xFF837DFF);
  static const appColor = Color(0xFF3840F7);
  static const nameUserColor = Color(0xFF182952);
  static const emailUserColor = Color(0xFF7E869B);
  static const userInformationBackgroundColor = Color(0xFFF5F5F7);
  static const searchBorderColor = Color(0xFFEAEAEA);
  static const searchHintTextColor = Color(0xFF7E869B);
  static const mailboxSelectedBackgroundColor = Color(0xFFE6E5FF);
  static const mailboxBackgroundColor = Color(0xFFFFFFFF);
  static const mailboxSelectedTextColor = Color(0xFF3840F7);
  static const mailboxTextColor = Color(0xFF182952);
  static const mailboxSelectedTextNumberColor = Color(0xFF182952);
  static const mailboxTextNumberColor = Color(0xFF837DFF);
  static const mailboxSelectedIconColor = Color(0xFF3840F7);
  static const mailboxIconColor = Color(0xFF7E869B);
  static const storageBackgroundColor = Color(0xFFF5F5F7);
  static const storageTitleColor = Color(0xFF7E869B);
  static const storageMaxSizeColor = Color(0xFF101D43);
  static const storageUseSizeColor = Color(0xFF2D0CFF);
  static const myFolderTitleColor = Color(0xFF7E869B);
  static const titleAppBarMailboxListMail = Color(0xFF182952);
  static const counterMailboxColor = Color(0xFF3840F7);
  static const backgroundCounterMailboxColor = Color(0xFFE6E5FF);
  static const backgroundCounterMailboxSelectedColor = Color(0x17313131);
  static const bgMailboxListMail = Color(0xFFFBFBFF);
  static const bgMessenger = Color(0xFFF2F2F5);
  static const textButtonColor = Color(0xFF182952);
  static const attachmentFileBorderColor = Color(0xFFEAEAEA);
  static const attachmentFileNameColor = Color(0xFF182952);
  static const attachmentFileSizeColor = Color(0xFF7E869B);
  static const avatarColor = Color(0xFFF8F8F8);
  static const avatarTextColor = Color(0xFF3840F7);
  static const sentTimeTextColorUnRead = Color(0xFF182952);
  static const subjectEmailTextColorUnRead = Color(0xFF3840F7);
  static const dividerColor = Color(0xFFEAEAEA);
  static const bgComposer = Color(0xFFFBFBFF);
  static const emailAddressChipColor = Color(0x0D001C3D);
  static const enableSendEmailButtonColor = Color(0xFF007AFF);
  static const disableSendEmailButtonColor = Color(0xFFA9B4C2);
  static const borderLeftEmailContentColor = Color(0xFFEFEFEF);
  static const toastBackgroundColor = Color(0xFFACAFFF);
  static const toastSuccessBackgroundColor = Color(0xFF04AA11);
  static const toastErrorBackgroundColor = Color(0xFFFF5858);
  static const toastWithActionBackgroundColor = Color(0xFF3F3F3F);
  static const buttonActionToastWithActionColor = Color(0xFF7ADCF8);
  static const backgroundCountAttachment = Color(0x681C1C1C);
  static const bgStatusResultSearch = Color(0xFFF5F5F7);
  static const bgWordSearch = Color(0xFFD7D6FC);
  static const lineItemListColor = Color(0xFF99A2AD);
  static const colorNameEmail = Color(0xFF000000);
  static const colorContentEmail = Color(0xFF6D7885);
  static const colorTextButton = Color(0xFF007AFF);
  static const colorHintSearchBar = Color(0xFF818C99);
  static const colorBgSearchBar = Color(0xFFEBEDF0);
  static const colorShadowBgContentEmail = Color(0x14000000);
  static const colorDividerMailbox = Color(0xFF99A2AD);
  static const colorCollapseMailbox = Color(0xFFB8C1CC);
  static const colorExpandMailbox = Color(0xFF007AFF);
  static const colorBgMailbox = Color(0xFFF7F7F7);
  static const colorFilterMessageDisabled = Color(0xFF99A2AD);
  static const colorFilterMessageEnabled = Color(0xFF007AFF);
  static const colorDefaultCupertinoActionSheet = Color(0x66000000);
  static const colorDisableMailboxCreateButton = Color(0x2E3C3C43);
  static const colorInputBorderErrorVerifyName = Color(0xFFE64646);
  static const colorInputBorderCreateMailbox = Color(0x1F000000);
  static const colorInputBackgroundErrorVerifyName = Color(0xFFFAEBEB);
  static const colorInputBackgroundCreateMailbox = Color(0xFFF2F3F5);
  static const colorHintInputCreateMailbox = Color(0xFFA9B4C2);
  static const colorMessageConfirmDialog = Color(0xFF6D7885);
  static const colorActionDeleteConfirmDialog = Color(0xFFE64646);
  static const colorActionCancelDialog = Color(0xFF007AFF);
  static const colorMessageDialog = Color(0xFF222222);
  static const colorConfirmActionDialog = Color(0xFFF2F2F2);
  static const colorEmailAddress = Color(0xFF333333);
  static const colorHintEmailAddressInput = Color(0x993C3C43);
  static const colorDividerComposer = Color(0xFFC6C6C8);
  static const colorDividerEmailView = Color(0xFFD7D8D9);
  static const colorButton = Color(0xFF959DAD);
  static const colorTime = Color(0xFF92A1B4);
  static const colorEmailAddressPrefix = Color(0xFF9AA7B6);
  static const colorEmailAddressTag = Color(0x146D7885);
  static const colorLineLeftEmailView = Color(0x2999A2AD);
  static const colorShadowComposer = Color(0x1F000000);
  static const colorBottomBarComposer = Color(0x5CEBEDF0);
  static const colorShadowComposerFullScreen = Color(0x33000000);
  static const colorCancelButton = Color(0xFFF2F2F2);
  static const colorTextButtonHeaderThread = Color(0xFF686E76);
  static const colorButtonHeaderThread = Color(0x99EBEDF0);
  static const colorBorderBodyThread = Color(0x5CB8C1CC);
  static const colorBgDesktop = Color(0xFFF6F6F6);
  static const colorItemEmailSelectedDesktop = Color(0x0F007AFF);
  static const colorAvatar = Color(0xFFDE5E5E);
  static const colorFocusButton = Color(0x14818C99);
  static const colorBorderEmailAddressInvalid = Color(0xFFFF3347);
  static const colorBorderIdentityInfo = Color(0xFFE7E8EC);
  static const colorBgMailboxSelected = Color(0xFF99E4E8EC);
  static const colorLoading = Color(0x2999A2AD);
  static const colorActionButtonHover = Color(0xFFA2AAB3);
  static const colorBgMenuItemDropDownSelected = Color(0x80DEE2E7);
  static const colorButtonCancelDialog = Color(0x0D000000);

  static const mapGradientColor = [
    [Color(0xFF21D4FD), Color(0xFFB721FF)],
    [Color(0xFF38F9D7), Color(0xFF43E97B)],
    [Color(0xFF11E6F0), Color(0xFF4FACFE)],
    [Color(0xFFE88395), Color(0xFFEF9C8F)],
    [Color(0xFF8DDAD5), Color(0xFF00CDAC)],
    [Color(0xFFDE9AF5), Color(0xFFD670EE)],
  ];
}

