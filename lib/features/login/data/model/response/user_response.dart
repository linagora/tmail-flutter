import 'package:core/data/constants/constant.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/login/data/model/converter/user_id_converter.dart';

part 'user_response.g.dart';

@UserIdConverter()
@JsonSerializable()
class UserResponse with EquatableMixin  {

  @JsonKey(name: Constant.userId)
  final UserId userId;
  @JsonKey(name: Constant.firstName)
  final String firstName;
  @JsonKey(name: Constant.lastName)
  final String lastName;

  UserResponse(
    this.userId,
    this.firstName,
    this.lastName
  );

  factory UserResponse.fromJson(Map<String, dynamic> json) => _$UserResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UserResponseToJson(this);

  @override
  List<Object?> get props => [
    userId,
    firstName,
    lastName,
  ];
}

extension UserResponseExtension on UserResponse {
  User toUser() {
    return User(
      userId,
      firstName,
      lastName,
    );
  }
}