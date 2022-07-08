import 'package:core/core.dart';

class SavingLanguageApp extends UIState {

  SavingLanguageApp();

  @override
  List<Object?> get props => [];
}

class SaveLanguageAppSuccess extends UIState {

  SaveLanguageAppSuccess();

  @override
  List<Object?> get props => [];
}

class SaveLanguageAppFailure extends FeatureFailure {
  final dynamic exception;

  SaveLanguageAppFailure(this.exception);

  @override
  List<Object> get props => [exception];
}