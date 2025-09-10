import 'package:equatable/equatable.dart';

abstract class PreferencesConfig with EquatableMixin {

  Map<String, dynamic> toJson();

  @override
  List<Object?> get props => [];
}