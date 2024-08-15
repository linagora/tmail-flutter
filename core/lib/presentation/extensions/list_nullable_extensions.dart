
extension ListNullableExtensions<T> on List<T>? {
  bool get validateFilesTransfer => this?.any((type) => type == 'Files') ?? false;
}