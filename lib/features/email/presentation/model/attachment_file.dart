
import 'package:equatable/equatable.dart';
import 'package:http_parser/http_parser.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_body_part.dart';

class AttachmentFile with EquatableMixin {

  final PartId? partId;
  final Id? blobId;
  final UnsignedInt? size;
  final String? name;
  final MediaType? type;
  final String? cid;

  AttachmentFile(
    this.partId,
    this.blobId,
    this.size,
    this.name,
    this.type,
    this.cid
  );

  @override
  List<Object?> get props => [partId, blobId, size, name, type, cid];
}