
extension UriExtension on Uri {
  bool isBaseUrlValid() => origin.isNotEmpty;
}