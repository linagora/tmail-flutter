
import 'package:equatable/equatable.dart';
import 'package:http_parser/http_parser.dart';
import 'package:jmap_dart_client/http/converter/account_id_converter.dart';
import 'package:jmap_dart_client/http/converter/id_converter.dart';
import 'package:jmap_dart_client/http/converter/media_type_converter.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:model/email/attachment.dart';

part 'upload_response.g.dart';

@AccountIdConverter()
@MediaTypeConverter()
@IdConverter()
@JsonSerializable()
class UploadResponse with EquatableMixin  {

  final AccountId accountId;
  final Id blobId;
  final MediaType type;
  final int size;

  UploadResponse(this.accountId, this.blobId, this.type, this.size);

  factory UploadResponse.fromJson(Map<String, dynamic> json) => _$UploadResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UploadResponseToJson(this);

  @override
  List<Object?> get props => [accountId, blobId, type, size];
}

extension UploadResponseExtension on UploadResponse {
  Attachment toAttachment(String nameFile) {
    return Attachment(blobId: blobId, size: UnsignedInt(size), name: nameFile, type: type);
  }
}