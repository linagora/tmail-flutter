
enum ScreenDisplayMode {
  fullScreen,
  minimize,
  normal,
  hidden;

  bool isNotContentVisible() => this == minimize || this == hidden;
}