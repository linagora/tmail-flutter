# 52. Enable Semantics to support integration test on Web

Date: 2024-08-19

## Status

Accepted

## Context

All the UI in a Flutter app is rendered as a `Widget Tree`. So the widgets can't access the widget tree elements. 
So we have to use [Semantics](https://api.flutter.dev/flutter/widgets/Semantics-class.html)
so that when Flutter renders the `Widgets Tree`, it also maintains a second tree, called `Semantics Tree`, 
which helps us to easily access each element, widget of the user interface.

## Decision

1. How to enable Semantics:

- Enable `Semantics` in main function:

```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SemanticsBinding.instance.ensureSemantics();

  runApp(const TMailApp());
}
```

- To access any widget element we just need to wrap it in a `Sematics` widget and set a `label` for it

```dart
Semantics(
  label: 'Title-app',
  child: Text('Twake Mail'),
);
```

2. To ignore `Sematics` for a specific widget, when we have Semantics enabled

- Way 1: Set the `excludeSemantics: true` property of the `Semantics` widget

```dart
Semantics(
  label: 'Title-app',
  excludeSemantics: true,
  child: Text('Twake Mail'),
);
```

- Way 2: Use `ExcludeSemantics` widget instead of `Semantics` widget

```dart
ExcludeSemantics(
  child: Text('Twake Mail'),
);
```

3. For a widget to be treated as a text field in the Semantics Tree

Set the ` textField: true` property of the `Semantics` widget

```dart
Semantics(
  label: 'Subject-email',
  textField: true,
  child: TextField(),
);
```

## Consequences

- Enabling Semantics has given us easy access to the widget elements of each screen. Making `Integration test` implementation easy and efficient.

## Influence

Some widgets are not working due to Semantics overlap:

- Workaround: 
    - Ignore `Sematics` for a specific widget
    - Use the correct properties for each widget used (`textField, button, container,...`)


