import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/http/converter/id_converter.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:json_annotation/json_annotation.dart';

part 'delegate.g.dart';

/// A person I gave access to my mailbox.
@JsonSerializable(converters: [IdConverter()], createToJson: false)
class Delegate with EquatableMixin {
  final Id id;
  final String username;

  Delegate({required this.id, required this.username});

  factory Delegate.fromJson(Map<String, dynamic> json) => _$DelegateFromJson(json);

  @override
  List<Object?> get props => [id, username];
}
