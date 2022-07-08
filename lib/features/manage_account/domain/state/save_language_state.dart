import 'dart:ui';

import 'package:core/core.dart';

class SavingLanguage extends UIState {

  SavingLanguage();

  @override
  List<Object?> get props => [];
}

class SaveLanguageSuccess extends UIState {

  final Locale localeStored;

  SaveLanguageSuccess(this.localeStored);

  @override
  List<Object?> get props => [localeStored];
}

class SaveLanguageFailure extends FeatureFailure {
  final dynamic exception;

  SaveLanguageFailure(this.exception);

  @override
  List<Object> get props => [exception];
}