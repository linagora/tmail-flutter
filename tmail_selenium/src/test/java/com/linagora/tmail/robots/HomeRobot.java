package com.linagora.tmail.robots;

import com.linagora.tmail.base.CoreRobot;
import com.microsoft.playwright.Page;

public class HomeRobot extends CoreRobot {

    public HomeRobot(Page page) {
        super(page);
    }

    public void navigateToTestSite(String url) {
        page.navigate(url);
    }
}
