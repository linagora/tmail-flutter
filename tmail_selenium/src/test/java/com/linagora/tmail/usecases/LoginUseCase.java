package com.linagora.tmail.usecases;

import org.openqa.selenium.WebDriver;
import org.openqa.selenium.support.ui.WebDriverWait;

import com.linagora.tmail.base.UseCase;
import com.linagora.tmail.robots.HomeRobot;
import com.linagora.tmail.robots.LoginRobot;
import com.linagora.tmail.robots.MailboxDashboardRobot;

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
    public void execute(WebDriver webDriver, WebDriverWait wait) {
        HomeRobot homeRobot = new HomeRobot(webDriver, wait);
        LoginRobot loginRobot = new LoginRobot(webDriver, wait);
        MailboxDashboardRobot mailboxDashboardRobot = new MailboxDashboardRobot(webDriver, wait);

        homeRobot.navigateToTestSite(testUrl);

        loginRobot.enterUsername(username);
        loginRobot.enterPassword(password);
        loginRobot.clickLogin();

        mailboxDashboardRobot.waitUntilExactLabelIsVisible("Compose");

        testUtils.waitFor(2);

        mailboxDashboardRobot.clickSentMailbox();

        testUtils.waitFor(2);

        mailboxDashboardRobot.checkIfThereAreMoreThanOneEmailSentBy(username);
    }

}
