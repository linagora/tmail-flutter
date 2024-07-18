package com.linagora.tmail.usecases;

import java.util.ArrayList;
import java.util.List;

import com.linagora.tmail.base.UseCase;
import com.linagora.tmail.robots.ComposerRobot;
import com.linagora.tmail.robots.MailboxDashboardRobot;
import com.microsoft.playwright.Page;

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
    public void execute(Page page) {
        MailboxDashboardRobot mailboxDashboardRobot = new MailboxDashboardRobot(page);
        ComposerRobot composerRobot = new ComposerRobot(page);

        LoginUseCase loginUseCase = new LoginUseCase(testUrl, username, password);
        loginUseCase.execute(page);

        mailboxDashboardRobot.openComposer();

        composerRobot.addReceipients(new ArrayList<String>(List.of(username, additionalReceipent)));
        composerRobot.addSubject("Test subject");
        composerRobot.addContent("Test content");
        composerRobot.clickSend();

        mailboxDashboardRobot.waitForSendEmailSuccessToast();
    }

}
