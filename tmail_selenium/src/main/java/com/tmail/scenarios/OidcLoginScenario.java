package com.tmail.scenarios;

import com.microsoft.playwright.Page;
import com.tmail.base.BaseScenario;
import com.tmail.robots.HomeRobot;
import com.tmail.robots.MailboxDashboardRobot;
import com.tmail.robots.OidcLoginRobot;

public class OidcLoginScenario extends BaseScenario {
    String testUrl;
    String username;
    String password;

    public OidcLoginScenario(String testUrl, String username, String password) {
        this.testUrl = testUrl;
        this.username = username;
        this.password = password;
    }

    @Override
    public void execute(Page page) {
        HomeRobot homeRobot = new HomeRobot(page);
        OidcLoginRobot loginRobot = new OidcLoginRobot(page);
        MailboxDashboardRobot mailboxDashboardRobot = new MailboxDashboardRobot(page);

        homeRobot.navigateToTestSite(testUrl);

        loginRobot.enterUsername(username);
        loginRobot.enterPassword(password);
        loginRobot.clickLogin();

        mailboxDashboardRobot.waitUntilExactLabelIsVisible("Compose");
    }

}
