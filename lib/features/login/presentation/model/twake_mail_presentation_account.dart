
import 'package:flutter/material.dart';
import 'package:linagora_design_flutter/multiple_account/models/twake_presentation_account.dart';
import 'package:model/account/personal_account.dart';

class TwakeMailPresentationAccount extends TwakePresentationAccount {

  final PersonalAccount personalAccount;

  const TwakeMailPresentationAccount({
    required this.personalAccount,
    required String accountName,
    required String accountId,
    required Widget avatar,
    required AccountActiveStatus accountActiveStatus,
  }) : super(
    accountName: accountName,
    accountId: accountId,
    avatar: avatar,
    accountActiveStatus: accountActiveStatus,
  );

  @override
  List<Object?> get props => [
    personalAccount,
    accountName,
    accountId,
    avatar,
    accountActiveStatus,
  ];
}