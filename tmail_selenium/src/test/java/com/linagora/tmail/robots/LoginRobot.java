package com.linagora.tmail.robots;

import com.linagora.tmail.base.CoreRobot;
import com.microsoft.playwright.Page;

public class LoginRobot extends CoreRobot {

    public LoginRobot(Page page) {
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
