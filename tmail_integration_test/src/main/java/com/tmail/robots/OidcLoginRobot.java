package com.tmail.robots;

import com.microsoft.playwright.Page;
import com.tmail.base.CoreRobot;

public class OidcLoginRobot extends CoreRobot {

    public OidcLoginRobot(Page page) {
        super(page);
    }

    public void enterUsername(String username) {
        page.locator("#username").fill(username);
    }

    public void enterPassword(String password) {
        page.locator("#password").fill(password);
    }

    public void clickLogin() {
        page.locator("#kc-login").click();
    }

}
