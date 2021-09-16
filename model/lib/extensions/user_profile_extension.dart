import 'package:model/model.dart';

extension UserProfileExtension on UserProfile {
  UserProfileResponse toUserProfileResponse() {
    return UserProfileResponse(email);
  }
}