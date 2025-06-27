
import 'package:equatable/equatable.dart';
import 'package:hive_ce/hive.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';

part 'attachment_hive_cache.g.dart';

@HiveType(typeId: CachingConstants.ATTACHMENT_HIVE_CACHE_ID)
class AttachmentHiveCache extends HiveObject with EquatableMixin {

  @HiveField(0)
  final String? partId;

  @HiveField(1)
  final String? blobId;

  @HiveField(2)
  final int? size;

  @HiveField(3)
  final String? name;

  @HiveField(4)
  final String? type;

  @HiveField(5)
  final String? cid;

  @HiveField(6)
  final String? disposition;

  AttachmentHiveCache({
    this.partId,
    this.blobId,
    this.size,
    this.name,
    this.type,
    this.cid,
    this.disposition
  });

  @override
  List<Object?> get props => [
    partId,
    blobId,
    size,
    name,
    type,
    cid,
    disposition
  ];
}