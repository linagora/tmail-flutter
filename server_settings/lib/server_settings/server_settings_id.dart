import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';

enum ServerSettingsIdType {
  singleton('singleton');

  const ServerSettingsIdType(this.value);

  final String value;
}

class ServerSettingsId with EquatableMixin {
  final Id id;

  ServerSettingsId({required this.id});

  @override
  List<Object?> get props => [id];
}

extension ServerSettingsIdExtension on ServerSettingsId {
  static ServerSettingsId get serverSettingsIdSingleton => ServerSettingsId(id: Id(ServerSettingsIdType.singleton.value));
}
