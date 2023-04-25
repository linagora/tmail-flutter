
extension MapExtensions<K, V> on Map<K, V> {

  Map<K, V> where(bool Function(K, V) condition) {
    Map<K, V> result = {};
    for (var element in entries) {
      if (condition(element.key, element.value)) {
        result[element.key] = element.value;
      }
    }
    return result;
  }
}
