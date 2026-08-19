abstract class AbstractSearchEmailActionRobot {
  Future<void> selectEmailWithSubject(String subject);
  Future<void> markSelectedEmailsAsRead();
  Future<void> archiveSelectedEmails();
}
