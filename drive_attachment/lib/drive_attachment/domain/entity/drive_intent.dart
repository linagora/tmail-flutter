import 'package:equatable/equatable.dart';

class DriveIntent with EquatableMixin {
  final String intentId;
  final Uri intentUrl;

  const DriveIntent({required this.intentId, required this.intentUrl});

  @override
  List<Object?> get props => [intentId, intentUrl];
}
