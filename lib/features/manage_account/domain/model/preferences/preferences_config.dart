import 'package:equatable/equatable.dart';

abstract class PreferencesConfig with EquatableMixin {
  String get configKey;

  Map<String, dynamic> toJson();

  @override
  List<Object?> get props => [];
}