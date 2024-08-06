package com.tmail.robots;

import com.microsoft.playwright.Page;
import com.tmail.base.CoreRobot;

public class MailboxDashboardRobot extends CoreRobot {

    public MailboxDashboardRobot(Page page) {
        super(page);
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
