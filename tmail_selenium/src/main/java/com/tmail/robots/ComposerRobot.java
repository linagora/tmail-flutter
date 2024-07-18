package com.tmail.robots;

import java.util.ArrayList;
import java.util.regex.Pattern;

import com.microsoft.playwright.FrameLocator;
import com.microsoft.playwright.Locator;
import com.microsoft.playwright.Page;
import com.tmail.base.CoreRobot;

public class ComposerRobot extends CoreRobot {

    public ComposerRobot(Page page) {
        super(page);
    }

    public void addReceipients(ArrayList<String> recipients) {
        Locator toFieldSelector = page.getByLabel("Composer:to").locator("input");
        toFieldSelector.click();
        for (String recipient : recipients) {
            toFieldSelector.fill(recipient);
            page.getByText(Pattern.compile("Composer:suggestion:" + recipient)).click();
        }
        page.keyboard().press("Tab");
        page.waitForTimeout(1000);
    }

    public void addSubject(String subject) {
        page.getByLabel("Composer:subject").fill(subject);
        page.keyboard().press("Tab");
    }

    public void addContent(String content) {
        FrameLocator frameLocator = page.frameLocator("iFrame");
        frameLocator.locator(".note-editable").fill(content);
    }

    public void clickSend() {
        page.getByText("Send").click();
    }

}
