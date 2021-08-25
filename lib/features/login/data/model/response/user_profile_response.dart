import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/login/data/model/converter/avatar_id_converter.dart';
import 'package:tmail_ui_user/features/login/data/model/converter/avatar_id_nullable_converter.dart';
import 'package:tmail_ui_user/features/login/data/model/converter/user_id_converter.dart';
import 'package:tmail_ui_user/features/login/data/model/response/presentation_account_response.dart';
import 'package:tmail_ui_user/features/login/data/utils/attribute.dart';

part 'user_profile_response.g.dart';

@AvatarIdNullableConverter()
@AvatarIdConverter()
@UserIdConverter()
@JsonSerializable()
class UserProfileResponse with EquatableMixin  {

  @JsonKey(name: Attribute.id, includeIfNull: false)
  final UserId id;
  @JsonKey(name: Attribute.firstname, includeIfNull: false)
  final String? firstName;
  @JsonKey(name: Attribute.lastname, includeIfNull: false)
  final String? lastName;
  @JsonKey(name: Attribute.job_title, includeIfNull: false)
  final String? jobTitle;
  @JsonKey(includeIfNull: false)
  final String? service;
  @JsonKey(name: Attribute.building_location, includeIfNull: false)
  final String? buildingLocation;
  @JsonKey(name: Attribute.office_location, includeIfNull: false)
  final String? officeLocation;
  @JsonKey(name: Attribute.main_phone, includeIfNull: false)
  final String? mainPhone;
  @JsonKey(includeIfNull: false)
  final String? description;
  @JsonKey(includeIfNull: false)
  final AvatarId? currentAvatar;
  @JsonKey(includeIfNull: false)
  final List<AvatarId>? avatars;
  @JsonKey(includeIfNull: false)
  final List<PresentationAccountResponse>? accounts;

  UserProfileResponse(
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
    this.accounts
  );

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) => _$UserProfileResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileResponseToJson(this);

  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    accounts,
  ];
}

extension UserProfileResponseExtension on UserProfileResponse {
  UserProfile toUserProfile() {
    return UserProfile(
      id,
      firstName ?? '',
      lastName ?? '',
      jobTitle ?? '',
      service ?? '',
      buildingLocation ?? '',
      officeLocation ?? '',
      mainPhone ?? '',
      description ?? '',
      currentAvatar ?? AvatarId.initial(),
      avatars ?? [],
      accounts != null ? accounts!.map((account) => account.toPresentationAccount()).toList() : []
    );
  }
}