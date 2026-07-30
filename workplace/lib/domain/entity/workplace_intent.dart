import 'package:equatable/equatable.dart';

class WorkplaceIntent with EquatableMixin {
  final String intentId;
  final Uri intentUrl;
  final String? client;

  const WorkplaceIntent({
    required this.intentId,
    required this.intentUrl,
    this.client,
  });

  @override
  List<Object?> get props => [intentId, intentUrl, client];
}
