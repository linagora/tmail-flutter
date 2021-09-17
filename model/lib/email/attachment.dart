
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

  Attachment({
    this.partId,
    this.blobId,
    this.size,
    this.name,
    this.type,
    this.cid
  });

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

  @override
  List<Object?> get props => [partId, blobId, size, name, type, cid];
}