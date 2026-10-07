import 'package:flutter/foundation.dart';
import 'package:marionette_flutter/marionette_flutter.dart';

import 'composer/composer_body_driver.dart';
import 'marionette_composer_schema.dart';

void registerComposerExtensions(ComposerBodyDriver driver) {
  registerMarionetteExtension(
    name: setBodyExtensionName,
    description: setBodyDescription,
    inputSchema: setBodyInputSchema,
    callback: (params) => handleSetBody(driver, params),
  );

  registerMarionetteExtension(
    name: getBodyExtensionName,
    description: getBodyDescription,
    callback: (_) => handleGetBody(driver),
  );
}

@visibleForTesting
Future<MarionetteExtensionResult> handleSetBody(
  ComposerBodyDriver driver,
  Map<String, String> params,
) async {
  final text = params['text'];
  if (text == null) return missingTextParam();
  return _toExtensionResult(await driver.setBody(text));
}

@visibleForTesting
Future<MarionetteExtensionResult> handleGetBody(
  ComposerBodyDriver driver,
) async {
  return _toExtensionResult(await driver.getBody());
}

MarionetteExtensionResult _toExtensionResult(ComposerBodyResult result) {
  return switch (result) {
    ComposerBodyFound(:final body) => MarionetteExtensionResult.success(body),
    ComposerNotFound() => noComposerOpen(),
    MultipleComposersFound() => multipleComposersOpen(),
  };
}
