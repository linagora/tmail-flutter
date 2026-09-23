/// A request body plus the extra entries the web blob adapter keys on.
/// Built by the caller so this package never imports the app's upload layer.
class WorkplaceUploadSource {
  final Object? requestData;
  final Map<String, dynamic> requestExtra;

  const WorkplaceUploadSource({
    this.requestData,
    this.requestExtra = const {},
  });
}
