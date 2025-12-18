import 'package:scribe/scribe/ai/localizations/scribe_localizations.dart';

enum AiScribeSuggestionActions {
  replace,
  insert;

  String getLabel(ScribeLocalizations localizations) {
    switch (this) {
      case AiScribeSuggestionActions.replace:
        return localizations.replace;
      case AiScribeSuggestionActions.insert:
        return localizations.insert;
    }
  }
}
