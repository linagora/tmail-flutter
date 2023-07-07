import 'dart:ui';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class SavingLanguage extends UIState {}

class SaveLanguageSuccess extends UIState {

  final Locale localeStored;

  SaveLanguageSuccess(this.localeStored);

  @override
  List<Object?> get props => [localeStored];
}

class SaveLanguageFailure extends FeatureFailure {

  SaveLanguageFailure(dynamic exception) : super(exception: exception);
}