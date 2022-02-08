
extension CapitalizeExtension on String {
  String get inCaps => this.length > 0 ?'${this[0].toUpperCase()}${this.toLowerCase().substring(1)}':'';
  String get allInCaps => this.toUpperCase();
  String get capitalizeFirstEach => this.replaceAll(RegExp(' +'), ' ').split(" ").map((str) => str.inCaps).join(" ");
}