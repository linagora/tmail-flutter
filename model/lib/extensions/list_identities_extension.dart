
import 'package:jmap_dart_client/jmap/identities/identity.dart';

extension ListIdentitiesExtension on List<Identity> {

  void sortByMayDelete() {
    sort((identity1, identity2) {
      if (identity1.mayDelete == false && identity2.mayDelete == true) {
        return -1;
      } if (identity1.mayDelete == true && identity2.mayDelete == false) {
        return 1;
      } else {
        return 0;
      }
    });
  }
}