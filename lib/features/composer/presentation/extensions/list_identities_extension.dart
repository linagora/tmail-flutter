
import 'package:jmap_dart_client/jmap/identities/identity.dart';

extension ListIdentitiesExtension on List<Identity> {

  List<Identity> toListMayDeleted() => where((identity) => identity.mayDelete == true).toList();
}