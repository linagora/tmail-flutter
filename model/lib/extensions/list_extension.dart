
extension ListExtension<T> on List<T>? {

  List<T>? union(List<T>? other) {
    if (other != null) {
      this?.addAll(other);
    }
    return this;
  }
}