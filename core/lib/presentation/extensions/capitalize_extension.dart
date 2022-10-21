
extension CapitalizeExtension on String {
  String get inCaps => length > 0 ?'${this[0].toUpperCase()}${toLowerCase().substring(1)}':'';
  String get allInCaps => toUpperCase();
  String get capitalizeFirstEach => replaceAll(RegExp(' +'), ' ').split(" ").map((str) => str.inCaps).join(" ");
}