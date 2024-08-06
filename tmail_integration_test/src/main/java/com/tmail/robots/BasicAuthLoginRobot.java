package com.tmail.robots;

import com.microsoft.playwright.Page;
import com.tmail.base.CoreRobot;

public class BasicAuthLoginRobot extends CoreRobot {

    public BasicAuthLoginRobot(Page page) {
        super(page);
    }

    public void enterUsername(String username) {
        page.locator("#email").fill(username);
    }

    public void enterPassword(String password) {
        page.locator("input[aria-label='password']").click();
        page.waitForTimeout(1000);
        page.locator("input[aria-label='password']").fill(password);
    }

    public void clickLogin() {
        page.getByText("Sign in").last().click();
    }

}
