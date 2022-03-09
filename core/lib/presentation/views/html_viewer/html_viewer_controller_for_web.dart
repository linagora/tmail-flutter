import 'dart:convert';
import 'package:universal_html/html.dart' as html;

import 'package:flutter/foundation.dart';

class HtmlViewerControllerForWeb {

  HtmlViewerControllerForWeb();

  /// Manages the view ID for the [HtmlViewerControllerForWeb] on web
  String? _viewId;

  set viewId(String? viewId) => _viewId = viewId;

  /// Recalculates the height of the editor to remove any vertical scrolling.
  void recalculateHeight() {
    _evaluateJavascriptWeb(data: {
      'type': 'toIframe: getHeight',
    });
  }

  /// A function to quickly call a document.execCommand function in a readable format
  void execCommand(String command, {String? argument}) {
    _evaluateJavascriptWeb(data: {
      'type': 'toIframe: execCommand',
      'command': command,
      'argument': argument
    });
  }

  /// A function to execute JS passed as a [WebScript] to the editor. This should
  /// only be used on Flutter Web.
  Future<dynamic> evaluateJavascriptWeb(String name,
      {bool hasReturnValue = false}) async {
    _evaluateJavascriptWeb(data: {'type': 'toIframe: $name'});
    if (hasReturnValue) {
      var e = await html.window.onMessage.firstWhere(
          (element) => json.decode(element.data)['type'] == 'toDart: $name');
      return json.decode(e.data);
    }
  }

  /// Helper function to run javascript and check current environment
  void _evaluateJavascriptWeb({required Map<String, Object?> data}) async {
    if (kIsWeb) {
      data['view'] = _viewId;
      final jsonEncoder = JsonEncoder();
      var json = jsonEncoder.convert(data);
      html.window.postMessage(json, '*');
    } else {
      throw Exception('Non-Flutter Web environment detected');
    }
  }
}