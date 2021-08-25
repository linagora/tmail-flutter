import 'package:equatable/equatable.dart';
import 'package:model/account/account_type.dart';
import 'package:model/account/presentation_account.dart';
import 'package:model/user/avatar_id.dart';
import 'package:model/user/user_id.dart';

class UserProfile with EquatableMixin {

  final UserId id;
  final String firstName;
  final String lastName;
  final String jobTitle;
  final String service;
  final String buildingLocation;
  final String officeLocation;
  final String mainPhone;
  final String description;
  final AvatarId currentAvatar;
  final List<AvatarId> avatars;
  final List<PresentationAccount> accounts;

  UserProfile(
    this.id,
    this.firstName,
    this.lastName,
    this.jobTitle,
    this.service,
    this.buildingLocation,
    this.officeLocation,
    this.mainPhone,
    this.description,
    this.currentAvatar,
    this.avatars,
    this.accounts,
  );

  String? getEmailAddress() {
    try {
      final accountEmail = accounts.firstWhere((account) => account.type == AccountType.email);
      if (accountEmail.emails.isNotEmpty) {
        final preferredEmailIndex = accountEmail.preferredEmailIndex < 0 ? 0 : accountEmail.preferredEmailIndex;
        return accountEmail.emails[preferredEmailIndex].email;
      }
      return '';
    } catch(e) {
      return '';
    }
  }

  String getFullName() => '$firstName $lastName';

  String getNameDisplay() {
    if (getFullName().trim().isEmpty) {
      return getEmailAddress() != null ? getEmailAddress()! : '';
    }
    return getFullName();
  }

  bool isUserEmpty() => getFullName().trim().isEmpty || getEmailAddress() == null || getEmailAddress()!.isEmpty;

  String getAvatarText() {
    if (getFullName().trim().isNotEmpty) {
      return getFullName().substring(0, 1).toUpperCase();
    } else if (getEmailAddress() != null && getEmailAddress()!.isNotEmpty) {
      return getEmailAddress()![0].toUpperCase();
    }
    return '';
  }

  @override
  List<Object> get props => [
    id,
    firstName,
    lastName,
    jobTitle,
    service,
    buildingLocation,
    officeLocation,
    mainPhone,
    description,
    currentAvatar,
    avatars,
    accounts,
  ];
}