
enum ButtonState {
  enabled,
  disabled;

  double get opacity {
    switch(this) {
      case ButtonState.enabled:
        return 1.0;
      case ButtonState.disabled:
        return 0.4;
    }
  }
}