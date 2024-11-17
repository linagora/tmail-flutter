import 'package:core/presentation/views/quick_search/quick_search_suggestion_box.dart';
import 'package:flutter/material.dart';

/// Supply an instance of this class to the [TypeAhead.suggestionsBoxController]
/// property to manually control the suggestions box
class QuickSearchSuggestionsBoxController {
  QuickSearchSuggestionsBox? _suggestionsBox;
  FocusNode? _effectiveFocusNode;

  set suggestionsBox(QuickSearchSuggestionsBox? value) {
    _suggestionsBox = value;
  }

  set effectiveFocusNode(FocusNode? value) {
    _effectiveFocusNode = value;
  }

  /// Opens the suggestions box
  void open() {
    _effectiveFocusNode!.requestFocus();
  }

  bool isOpened() {
    return _suggestionsBox!.isOpened;
  }

  /// Closes the suggestions box
  void close() {
    _effectiveFocusNode!.unfocus();
  }

  /// Opens the suggestions box if closed and vice versa
  void toggle() {
    if (_suggestionsBox!.isOpened) {
      close();
    } else {
      open();
    }
  }

  /// Recalculates the height of the suggestions box
  void resize() {
    _suggestionsBox!.resize();
  }
}
