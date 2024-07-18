package com.linagora.tmail.usecases;

import com.linagora.tmail.base.UseCase;
import com.linagora.tmail.robots.HomeRobot;
import com.linagora.tmail.robots.LoginRobot;
import com.linagora.tmail.robots.MailboxDashboardRobot;
import com.microsoft.playwright.Page;

public class LoginUseCase extends UseCase {
    String testUrl;
    String username;
    String password;

    public LoginUseCase(String testUrl, String username, String password) {
        this.testUrl = testUrl;
        this.username = username;
        this.password = password;
    }

    @Override
    public void execute(Page page) {
        HomeRobot homeRobot = new HomeRobot(page);
        LoginRobot loginRobot = new LoginRobot(page);
        MailboxDashboardRobot mailboxDashboardRobot = new MailboxDashboardRobot(page);

        homeRobot.navigateToTestSite(testUrl);

        loginRobot.enterUsername(username);
        loginRobot.enterPassword(password);
        loginRobot.clickLogin();

        mailboxDashboardRobot.waitUntilExactLabelIsVisible("Compose");

        mailboxDashboardRobot.clickSentMailbox();

        testUtils.waitFor(2, page);

        mailboxDashboardRobot.checkIfThereAreMoreThanOneEmailSentBy(username);
    }

}
