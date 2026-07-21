import 'package:core/presentation/state/failure.dart';
import 'package:tmail_ui_user/features/thread/domain/state/search_email_state.dart';

/// Normalizes an executor error into a [SearchEmailFailure] for the retry UI.
SearchEmailFailure asSearchEmailFailure(Object? error) {
  if (error is SearchEmailFailure) return error;
  if (error is FeatureFailure) return SearchEmailFailure(error.exception);
  return SearchEmailFailure(error);
}
