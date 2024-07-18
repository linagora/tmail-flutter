package com.tmail.scenarios;

import java.util.ArrayList;
import java.util.List;

import com.microsoft.playwright.Page;
import com.tmail.base.BaseScenario;
import com.tmail.robots.ComposerRobot;
import com.tmail.robots.MailboxDashboardRobot;

public class ComposeEmailScenario extends BaseScenario {
    String testUrl;
    String username;
    String password;
    String additionalReceipent;

    public ComposeEmailScenario(String testUrl, String username, String password, String additionalReceipent) {
        this.testUrl = testUrl;
        this.username = username;
        this.password = password;
        this.additionalReceipent = additionalReceipent;
    }

    @Override
    public void execute(Page page) {
        MailboxDashboardRobot mailboxDashboardRobot = new MailboxDashboardRobot(page);
        ComposerRobot composerRobot = new ComposerRobot(page);

        LoginScenario loginUseCase = new LoginScenario(testUrl, username, password);
        loginUseCase.execute(page);

        mailboxDashboardRobot.openComposer();

        composerRobot.addReceipients(new ArrayList<String>(List.of(username, additionalReceipent)));
        composerRobot.addSubject("Test subject");
        composerRobot.addContent("Test content");
        composerRobot.clickSend();

        mailboxDashboardRobot.waitForSendEmailSuccessToast();
    }

}
