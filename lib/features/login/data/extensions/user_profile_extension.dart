import 'package:model/model.dart';
import 'package:tmail_ui_user/features/login/data/model/response/user_profile_response.dart';
import 'package:tmail_ui_user/features/login/data/extensions/presentation_account_extension.dart';

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