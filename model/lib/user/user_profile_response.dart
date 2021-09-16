import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:model/model.dart';

part 'user_profile_response.g.dart';

@JsonSerializable()
class UserProfileResponse with EquatableMixin  {

  final String email;

  UserProfileResponse(this.email);

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) => _$UserProfileResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileResponseToJson(this);

  @override
  List<Object?> get props => [email];
}

extension UserProfileResponseExtension on UserProfileResponse {
  UserProfile toUserProfile() {
    return UserProfile(email);
  }
}