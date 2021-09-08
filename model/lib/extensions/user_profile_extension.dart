import 'package:model/model.dart';

extension UserProfileExtension on UserProfile {
  UserProfileResponse toUserProfileResponse() {
    return UserProfileResponse(
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
      accounts.map((account) => account.toPresentationAccountResponse()).toList()
    );
  }
}