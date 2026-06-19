import 'package:patrol/patrol.dart';

abstract class AbstractMailboxFolderRobot {
  Future<void> tapAddNewFolderButton();
  Future<void> tapCreateNewSubFolder();
  Future<void> enterNewFolderName(String name);
  Future<void> confirmCreateNewFolder();
  Future<void> tapRenameMailbox();
  Future<void> enterRenameSubFolderName(String name);
  Future<void> confirmRenameSubFolder();
  Future<void> tapMoveMailbox();
  Future<void> tapDeleteMailbox();
  Future<void> confirmDeleteMailbox();
  Future<void> tapHideMailbox();
  Future<void> tapMoveFolderContentAction(PatrolFinder targetMailbox);
}
