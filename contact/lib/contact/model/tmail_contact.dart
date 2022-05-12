
import 'package:contact/contact/model/contact.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tmail_contact.g.dart';

@JsonSerializable()
class TMailContact extends Contact {

  final String id;
  final String emailAddress;

  @JsonKey(includeIfNull: false)
  final String? firstname;

  @JsonKey(includeIfNull: false)
  final String? surname;

  TMailContact(
    this.id,
    this.firstname,
    this.surname,
    this.emailAddress);

  factory TMailContact.fromJson(Map<String, dynamic> json) =>
      _$TMailContactFromJson(json);

  Map<String, dynamic> toJson() => _$TMailContactToJson(this);

  @override
  List<Object?> get props => [
    id,
    firstname,
    surname,
    emailAddress];
}