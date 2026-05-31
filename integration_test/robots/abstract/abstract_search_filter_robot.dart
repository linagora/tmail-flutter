abstract class AbstractSearchFilterRobot {
  // On web the filter bar is always visible — scroll no-ops are expected overrides.
  Future<void> scrollToEndListSearchFilter();
  Future<void> scrollToDateTimeButtonFilter();
  Future<void> openDateTimeBottomDialog();
  Future<void> selectDateTime(String dateTimeType);
  Future<void> openSortOrderMenu();
  Future<void> selectSortOrder(String sortOrderName);
  Future<void> selectAttachmentFilter();
  Future<void> openLabelListModal();
}
