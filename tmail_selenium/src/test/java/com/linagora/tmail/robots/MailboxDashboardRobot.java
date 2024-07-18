package com.linagora.tmail.robots;

import static org.junit.Assert.assertTrue;

import java.util.regex.Pattern;

import com.linagora.tmail.base.CoreRobot;
import com.microsoft.playwright.Page;

public class MailboxDashboardRobot extends CoreRobot {

    public MailboxDashboardRobot(Page page) {
        super(page);
    }

    public void clickSentMailbox() {
        page.getByText("Sent").waitFor();
        page.waitForTimeout(1000);
        page.getByText("Sent").click();
    }

    public void checkIfThereAreMoreThanOneEmailSentBy(String username) {
        assertTrue(page.getByLabel(Pattern.compile(username)).all().size() > 1);
    }

    public void openComposer() {
        page.getByText("Compose").click();
    }

    public void waitForSendEmailSuccessToast() {
        page.getByText("Message has been sent successfully").waitFor();
    }

    public void waitUntilExactLabelIsVisible(String string) {
        page.getByText(string).waitFor();
    }

}
