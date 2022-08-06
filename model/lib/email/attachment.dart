
import 'package:equatable/equatable.dart';
import 'package:http_parser/http_parser.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_body_part.dart';
import 'package:uri/uri.dart';

class Attachment with EquatableMixin {

  final PartId? partId;
  final Id? blobId;
  final UnsignedInt? size;
  final String? name;
  final MediaType? type;
  final String? cid;
  final ContentDisposition? disposition;

  Attachment({
    this.partId,
    this.blobId,
    this.size,
    this.name,
    this.type,
    this.cid,
    this.disposition,
  });

  bool noCid() => cid == null || cid?.isEmpty == true;

  bool hasCid() => cid != null && cid?.isNotEmpty == true;

  String getDownloadUrl(String baseDownloadUrl, AccountId accountId) {
    final downloadUriTemplate = UriTemplate('$baseDownloadUrl');
    final downloadUri = downloadUriTemplate.expand({
      'accountId' : '${accountId.id.value}',
      'blobId' : '${blobId?.value}',
      'name' : '$name',
      'type' : '${type?.mimeType}',
    });
    return Uri.decodeFull(downloadUri);
  }

  String generateFileName() {
    if (name?.isNotEmpty == true) {
      return name!;
    } else {
      return '${blobId?.value}.${type?.subtype}';
    }
  }

  @override
  List<Object?> get props => [partId, blobId, size, name, type, cid, disposition];
}

enum ContentDisposition {
  inline,
  attachment,
  other
}

extension ContentDispositionExtension on ContentDisposition {
  String get value {
    switch(this) {
      case ContentDisposition.inline:
        return 'inline';
      case ContentDisposition.attachment:
        return 'attachment';
      case ContentDisposition.other:
        return this.toString();
    }
  }
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