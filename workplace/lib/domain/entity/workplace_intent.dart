import 'package:equatable/equatable.dart';

class WorkplaceIntent with EquatableMixin {
  final String intentId;
  final Uri intentUrl;

  const WorkplaceIntent({required this.intentId, required this.intentUrl});

  @override
  List<Object?> get props => [intentId, intentUrl];
}
