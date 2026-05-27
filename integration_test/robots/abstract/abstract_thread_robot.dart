abstract class AbstractThreadRobot {
  Future<void> openComposer();
  Future<void> expectAppGridVisible();
  Future<void> openAppGrid();
  Future<void> openMailbox();
  Future<void> openEmailWithSubject(String subject);
  Future<void> expectTrashBannerVisible();
  Future<void> expectTrashBannerInvisible();
  Future<void> expectEmptyTrashThreadView();
  Future<void> confirmEmptyTrashViaBanner();
  Future<void> tapEmptyTrashBanner();
}
