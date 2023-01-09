abstract class StoreLastTimeDismissedSpamReportInteractor {
  Future<void> storeLastTimeDismissedSpamReported(DateTime lastTimeDismissedSpamReported);

  Future<DateTime> getLastTimeDismissedSpamReported();

  Future<void> deleteLastTimeDismissedSpamReported();
}