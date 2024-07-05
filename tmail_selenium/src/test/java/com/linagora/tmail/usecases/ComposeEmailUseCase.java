package com.linagora.tmail.usecases;

import java.util.ArrayList;
import java.util.List;

import org.openqa.selenium.WebDriver;
import org.openqa.selenium.support.ui.WebDriverWait;

import com.linagora.tmail.base.UseCase;
import com.linagora.tmail.robots.ComposerRobot;
import com.linagora.tmail.robots.MailboxDashboardRobot;

public class ComposeEmailUseCase extends UseCase {
    String testUrl;
    String username;
    String password;
    String additionalReceipent;

    public ComposeEmailUseCase(String testUrl, String username, String password, String additionalReceipent) {
        this.testUrl = testUrl;
        this.username = username;
        this.password = password;
        this.additionalReceipent = additionalReceipent;
    }

    @Override
    public void execute(WebDriver webDriver, WebDriverWait wait) {
        MailboxDashboardRobot mailboxDashboardRobot = new MailboxDashboardRobot(webDriver, wait);
        ComposerRobot composerRobot = new ComposerRobot(webDriver, wait);

        LoginUseCase loginUseCase = new LoginUseCase(testUrl, username, password);
        loginUseCase.execute(webDriver, wait);

        mailboxDashboardRobot.openComposer();

        composerRobot.addReceipients(new ArrayList<String>(List.of(username, additionalReceipent)));
        composerRobot.addSubject("Test subject");
        composerRobot.addContent("Test content");
        composerRobot.clickSend();

        mailboxDashboardRobot.waitForSendEmailSuccessToast();
    }

}
