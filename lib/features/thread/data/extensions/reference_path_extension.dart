import 'package:jmap_dart_client/jmap/core/request/reference_path.dart';

extension ReferencePathExtension on ReferencePath {
  static ReferencePath listThreadIdsPath = ReferencePath('/list/*/threadId');
}
