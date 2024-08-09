
extension ListExtension<T> on List<T>? {

  List<T>? unite(List<T>? other) {
    if (other != null) {
      this?.addAll(other);
    }
    return this;
  }

  bool notContains(T value) => this?.contains(value) != true;
}