import 'package:hive/hive.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';

class UriAdapter extends TypeAdapter<Uri> {
  @override
  final int typeId = CachingConstants.URI_CACHE_IDENTITY;

  @override
  Uri read(BinaryReader reader) {
    return Uri.parse(reader.readString());
  }

  @override
  void write(BinaryWriter writer, Uri obj) {
    writer.writeString(obj.toString());
  }

}