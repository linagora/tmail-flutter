import 'package:marionette_flutter/marionette_flutter.dart';

const setBodyExtensionName = 'tmailComposer.setBody';
const getBodyExtensionName = 'tmailComposer.getBody';

const setBodyDescription = 'Replaces the body of the open composer with the '
    'given plain text, keeping the signature. Each line becomes a paragraph.';
const getBodyDescription =
    'Returns the text and HTML of the open composer body.';

const setBodyInputSchema = ExtensionInputSchema(
  properties: {
    'text': ExtensionParam.string(description: 'Plain text body.'),
  },
  required: ['text'],
);

MarionetteExtensionResult missingTextParam() =>
    const MarionetteExtensionResult.invalidParams(
      'Missing required parameter: text',
    );

MarionetteExtensionResult noComposerOpen() =>
    const MarionetteExtensionResult.invalidParams(
      'No composer editor found. Open the composer first.',
    );
