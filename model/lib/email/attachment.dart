
import 'dart:convert';

import 'package:core/presentation/extensions/string_extension.dart';
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
  static const String _defaultName = 'unknown-attachment';
  static const int _maxFileNameBytes = 255;

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
    final rawName = (name?.trim().isNotEmpty == true)
        ? name!.trim()
        : (blobId != null
            ? (type?.subtype != null
                ? '${blobId!.value}.${type!.subtype}'
                : blobId!.value)
            : _defaultName);

    final sanitized = rawName.sanitizedBidiForDisplay
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .trim();
    final fileName = _limitToMaxFileNameBytes(sanitized);
    // Fall back if sanitized name has no meaningful content (e.g. '???' → '___')
    return fileName.contains(RegExp(r'[^_\s]')) ? fileName : _defaultName;
  }

  // Most filesystems reject a file name over 255 bytes, so shorten the base name and keep the extension.
  static String _limitToMaxFileNameBytes(String fileName) {
    if (utf8.encode(fileName).length <= _maxFileNameBytes) return fileName;

    final dotIndex = fileName.lastIndexOf('.');
    final extension = dotIndex > 0 ? fileName.substring(dotIndex) : '';
    final extensionBytes = utf8.encode(extension).length;
    if (extension.isEmpty || extensionBytes >= _maxFileNameBytes) {
      return _takeUtf8Bytes(fileName, _maxFileNameBytes).trimRight();
    }

    final baseName = fileName.substring(0, fileName.length - extension.length);
    return '${_takeUtf8Bytes(baseName, _maxFileNameBytes - extensionBytes)}$extension';
  }

  static String _takeUtf8Bytes(String value, int maxBytes) {
    final buffer = StringBuffer();
    var usedBytes = 0;
    for (final rune in value.runes) {
      usedBytes += _utf8ByteLength(rune);
      if (usedBytes > maxBytes) break;
      buffer.writeCharCode(rune);
    }
    return buffer.toString();
  }

  // A lone surrogate is encoded as U+FFFD, which takes 3 bytes like any other BMP rune.
  static int _utf8ByteLength(int rune) {
    if (rune < 0x80) return 1;
    if (rune < 0x800) return 2;
    if (rune < 0x10000) return 3;
    return 4;
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