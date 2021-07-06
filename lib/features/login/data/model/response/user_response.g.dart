// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserResponse _$UserResponseFromJson(Map<String, dynamic> json) {
  return UserResponse(
    const UserIdConverter().fromJson(json['_id'] as String),
    json['firstname'] as String,
    json['lastname'] as String,
  );
}

Map<String, dynamic> _$UserResponseToJson(UserResponse instance) =>
    <String, dynamic>{
      '_id': const UserIdConverter().toJson(instance.userId),
      'firstname': instance.firstName,
      'lastname': instance.lastName,
    };
