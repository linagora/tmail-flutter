
class EmptyFolderNameException implements Exception {
  final String folderName;

  EmptyFolderNameException(this.folderName);

  @override
  String toString() => 'EmptyFolderNameException: Folder name should not be empty: $folderName';
}
