import 'package:tmail_ui_user/features/manage_account/presentation/preferences/model/preference_option.dart';

/// The single place every [PreferenceOption] is collected.
///
/// This is the hand-rolled multibinder the codebase was already approximating
/// with the `_stringBuilders` / `_enabledResolvers` maps: a list populated once
/// (in the bindings) and iterated everywhere else. Adding a preference now means
/// writing one [PreferenceOption] and registering it here — no central switch to
/// edit.
class PreferenceOptionRegistry {
  PreferenceOptionRegistry(this._options);

  final List<PreferenceOption> _options;

  /// All registered options, in display order.
  List<PreferenceOption> get all => List.unmodifiable(_options);

  /// The options visible for the given [context], preserving registration order.
  List<PreferenceOption> available(PreferencesContext context) =>
      _options.where((option) => option.isAvailable(context)).toList();
}
