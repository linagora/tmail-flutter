import 'package:equatable/equatable.dart';
import 'package:core/utils/user_url_template.dart';

class PaywallUrlPattern with EquatableMixin {
  final String pattern;

  PaywallUrlPattern(this.pattern);

  /// Resolves [pattern], or null when a placeholder cannot be filled — a
  /// half-filled URL points at the wrong host.
  String? resolveQualifiedUrl({
    required String ownerEmail,
    String? domainName,
  }) => UserUrlTemplate(pattern).resolve(
      ownerEmail: ownerEmail,
      domainName: domainName,
    );

  @override
  List<Object> get props => [pattern];
}
