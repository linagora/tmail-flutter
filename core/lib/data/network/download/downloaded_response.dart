import 'package:equatable/equatable.dart';
import 'package:http_parser/http_parser.dart';

class DownloadedResponse with EquatableMixin {
  final String filePath;
  final MediaType? mediaType;

  DownloadedResponse(this.filePath, {this.mediaType});

  @override
  List<Object?> get props => [filePath, mediaType];
}