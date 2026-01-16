import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/http/converter/id_converter.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:labels/converter/hex_color_nullable_converter.dart';
import 'package:labels/converter/keyword_identifier_nullable_converter.dart';
import 'package:labels/model/hex_color.dart';

part 'label.g.dart';

@JsonSerializable(
  explicitToJson: true,
  includeIfNull: false,
  converters: [
    IdConverter(),
    HexColorNullableConverter(),
    KeywordIdentifierNullableConverter(),
  ],
)
class Label with EquatableMixin {
  final Id? id;
  final KeyWordIdentifier? keyword;
  final String? displayName;
  final HexColor? color;

  Label({
    this.id,
    this.keyword,
    this.displayName,
    this.color,
  });

  factory Label.fromJson(Map<String, dynamic> json) => _$LabelFromJson(json);

  Map<String, dynamic> toJson() => _$LabelToJson(this);

  @override
  List<Object?> get props => [
        id,
        keyword,
        displayName,
        color,
      ];
}
