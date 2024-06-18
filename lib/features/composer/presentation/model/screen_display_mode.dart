
enum ScreenDisplayMode {
  fullScreen,
  minimize,
  normal;

  factory ScreenDisplayMode.fromJson(String value) {
    switch (value) {
      case 'fullScreen':
        return ScreenDisplayMode.fullScreen;
      case 'minimize':
        return ScreenDisplayMode.minimize;
      default:
        return ScreenDisplayMode.normal;
    }
  }

  String toJson() => name;
}