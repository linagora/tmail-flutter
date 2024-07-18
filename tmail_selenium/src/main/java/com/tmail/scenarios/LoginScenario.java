package com.tmail.scenarios;

import com.microsoft.playwright.Page;
import com.tmail.base.BaseScenario;
import com.tmail.robots.HomeRobot;
import com.tmail.robots.LoginRobot;
import com.tmail.robots.MailboxDashboardRobot;

public class LoginScenario extends BaseScenario {
    String testUrl;
    String username;
    String password;

    public LoginScenario(String testUrl, String username, String password) {
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
