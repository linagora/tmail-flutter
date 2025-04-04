import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cozy_contact.g.dart';

@JsonSerializable(createToJson: false)
class CozyContact with EquatableMixin {
  final String? id;

  @JsonKey(name: '_id')
  final String? privateId;

  @JsonKey(name: '_type')
  final String? type;

  @JsonKey(name: '_rev')
  final String? rev;

  final List<CozyAccountUrl>? cozy;
  final String? displayName;
  final List<CozyEmail>? email;
  final String? fullname;
  final CozyIndexes? indexes;
  final bool? me;

  CozyContact({
      this.id,
      this.privateId,
      this.type,
      this.rev,
      this.cozy,
      this.displayName,
      this.email,
      this.fullname,
      this.indexes,
      this.me,
  });

  factory CozyContact.fromJson(Map<String, dynamic> json) => _$CozyContactFromJson(json);

  @override
  List<Object?> get props => [id, privateId, type, rev, cozy, displayName, email, fullname, indexes, me];

  @override
  bool? get stringify => true;
}

@JsonSerializable(createToJson: false)
class CozyAccountUrl with EquatableMixin {
  final bool? primary;
  final String? url;

  CozyAccountUrl({
      this.primary,
      this.url,
  });

  factory CozyAccountUrl.fromJson(Map<String, dynamic> json) => _$CozyAccountUrlFromJson(json);

  @override
  List<Object?> get props => [primary, url];
}

@JsonSerializable(createToJson: false)
class CozyEmail with EquatableMixin {
  final String? address;
  final bool? primary;

  CozyEmail({
      this.address,
      this.primary,
  });

  factory CozyEmail.fromJson(Map<String, dynamic> json) => _$CozyEmailFromJson(json);

  @override
  List<Object?> get props => [address, primary];
}

@JsonSerializable(createToJson: false)
class CozyIndexes with EquatableMixin {
  final String? byFamilyNameGivenNameEmailCozyUrl;

  CozyIndexes({
      this.byFamilyNameGivenNameEmailCozyUrl,
  });

  factory CozyIndexes.fromJson(Map<String, dynamic> json) => _$CozyIndexesFromJson(json);

  @override
  List<Object?> get props => [byFamilyNameGivenNameEmailCozyUrl];
}