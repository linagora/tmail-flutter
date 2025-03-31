
import 'package:equatable/equatable.dart';
import 'package:http_parser/http_parser.dart';
import 'package:jmap_dart_client/http/converter/id_nullable_converter.dart';
import 'package:jmap_dart_client/http/converter/media_type_nullable_converter.dart';
import 'package:jmap_dart_client/http/converter/part_id_nullable_converter.dart';
import 'package:jmap_dart_client/http/converter/unsigned_int_nullable_converter.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_body_part.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uri/uri.dart';

part 'attachment.g.dart';

@JsonSerializable(
  includeIfNull: false,
  explicitToJson: true,
  converters: [
    PartIdNullableConverter(),
    IdNullableConverter(),
    UnsignedIntNullableConverter(),
    MediaTypeNullableConverter(),
  ],
)
class Attachment with EquatableMixin {

  static const String eventICSSubtype = 'ics';
  static const String eventCalendarSubtype = 'calendar';
  static const String applicationRTFType = 'application/rtf';

  final PartId? partId;
  final Id? blobId;
  final UnsignedInt? size;
  final String? name;
  final MediaType? type;
  final String? cid;
  final ContentDisposition? disposition;
  final String? charset;

  Attachment({
    this.partId,
    this.blobId,
    this.size,
    this.name,
    this.type,
    this.cid,
    this.disposition,
    this.charset,
  });

  bool noCid() => cid == null || cid?.isEmpty == true;

  bool hasCid() => cid != null && cid?.isNotEmpty == true;

  bool isDispositionInlined() => disposition == ContentDisposition.inline;

  bool isDispositionUndefined() => disposition == null;

  bool isApplicationRTFInlined() => type?.mimeType == applicationRTFType && isDispositionInlined();

  String getDownloadUrl(String baseDownloadUrl, AccountId accountId) {
    final downloadUriTemplate = UriTemplate(baseDownloadUrl);
    final downloadUri = downloadUriTemplate.expand({
      'accountId' : accountId.id.value,
      'blobId' : '${blobId?.value}',
      'name' : name ?? '',
      'type' : type?.mimeType ?? '',
    });
    return downloadUri;
  }

  String generateFileName() {
    if (name?.isNotEmpty == true) {
      return name!;
    } else {
      return '${blobId?.value}.${type?.subtype}';
    }
  }

  factory Attachment.fromJson(Map<String, dynamic> json) => _$AttachmentFromJson(json);

  Map<String, dynamic> toJson() => _$AttachmentToJson(this);

  @override
  List<Object?> get props => [
    partId,
    blobId,
    size,
    name,
    type,
    cid,
    disposition,
    charset
  ];
}

enum ContentDisposition {
  inline,
  attachment,
  other
}

extension DispositionStringExtension on String? {
  ContentDisposition? toContentDisposition() {
    if (this != null) {
      switch(this) {
        case 'inline':
          return ContentDisposition.inline;
        case 'attachment':
          return ContentDisposition.attachment;
        default:
          return ContentDisposition.other;
      }
    }
    return null;
  }
}