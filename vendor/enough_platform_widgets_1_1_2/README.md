# enough_platform_widgets
[![enough_platform_widgets version](https://img.shields.io/pub/v/enough_platform_widgets.svg)](https://pub.dartlang.org/packages/enough_platform_widgets)

More cross platform widgets for Flutter developers.

Based on these great packages:
* [flutter_platform_widgets](https://pub.dev/packages/flutter_platform_widgets)
* [cupertino_stepper](cupertino_stepper)

Licensed commercially friendly under the [MIT License](LICENSE).

## Installation
Add this as a dependency to your `pubspec.yaml`:
```
dependencies:
  enough_platform_widgets: ^1.0.0
```

## Flutter Versions
* Use 1.0 or higher for Flutter 3.16+
* Use 0.7.4 for previous Flutter versions


## Platform Widgets and Methods
Platform widgets use their material or cupertino equivalent based on the chosen platform.

* `DecoratedPlatformTextField` provides a cross platform replacement for the material `TextField`
* `DensePlatformIconButton` replaces the material `IconButton`
* `DialogHelper` helps to show platform specific dialogs
* `PlatformBottomBar` shows a `BottomAppBar` on material and a `CupertinoBar` on cupertino
* `PlatformCheckboxListTile` is a platform aware simple checkbox list tile
* `PlatformChip` a simple cross-platform `Chip` replacement
* `PlatformDialogActionButton` is a platform aware dialog action
* `PlatformDialogActionText` provides a platform aware dialog action text
* `PlatformDropdownButton` is a replacement for the material `DropdownButton`
* `PlatformFilledButtonIcon` uses an `ElevatedButton.filled` on material and a `CupertinoButton.filled` on cupertino
* `PlatformInkWell` is a rectangular area of a that responds to touch and is based either on `InkWell` or on `CupertinoInkWell`
* `PlatformPageScaffold` provides a `PlatformScaffold` with the additional option to define a bottom bar.
* `PlatformPopupButton` uses an action sheet on cupertino and a popup button on material.
* `PlatformProgressIndicator` uses a `CircularProgressIndicator` on material and a `CupertinoActivityIndicator` on cupertino
* `PlatformRadioListTile` provides a RadioListTile implementation for both material and cupertino
* `PlatformSliverAppBar` uses a `SliverAppBar` on material or a `CupertinoSliverNavigationBar` on cupertino
* `PlatformSnackApp` is a base app that allows to show SnackBars on cupertino as well
* `PlatformStepper` abstracts the `Stepper` material widget
* `PlatformTextButtonIcon` is a simple replacement for `TextButton.icon`
* `PlatformToggleButtons` provides a platform aware `ToggleButtons` replacement
* `PlatformToolbar` provides a toolbar option
* `SelectablePlatformListTile` provides a ListTile implementation for both material and cupertino
* `showPlatformTimePicker()` displays a platform aware time picker
* `showPlatformDatePicker()` displays a platform aware date picker
* Additionally, all [flutter_platform_widgets](https://pub.dev/packages/flutter_platform_widgets) are available.

## Cupertino Widgets
Currently the following cupertino widgets are provided:
* `CupertinoBar` is a simple cupertino bar that either blurs the background or provides a translucent background
* `CupertinoCheckboxListTile` provides a simple cupertino style checkbox list tile
* `CupertinoChip` is a cupertino version of the material `Chip` widget
* `CupertinoDropdownButton` maps the basic dropdown feature to a `CupertinoPicker`
* `CupertinoInkWell` is a rectangular area of a that responds to touch
* `CupertinoMultipleSegmentedControl` is like the `CupertinoSegmentedControl` but it allows to select several segments at once
* `CupertinoPageScaffoldWithToolbar` provides a scaffold with the option to define a toolbar widget
* `CupertinoPageWithBar` is a simple page with a bar that can be aligned top/bottom/left/right
* `CupertinoRadioListTile` provides a simple cupertino style radio list tile
* `CupertinoSearchFlowTextField` displays a CupertinoSearchTextField with the expected UX flow that switches to a full-screen experience once editing starts
* `CupertinoSnackApp` is a CupertinoApp that also allows to display snack bar messages
* `CupertinoToolbar` a simple wrapper for a cupertino toolbar widget 

## API Documentation
Check out the full API documentation at https://pub.dev/documentation/enough_platform_widgets/latest/

## Thanks to all Contributors!!
<a href="https://github.com/Enough-Software/enough_platform_widgets/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=Enough-Software/enough_platform_widgets" />
</a>

Made with [contrib.rocks](https://contrib.rocks).
