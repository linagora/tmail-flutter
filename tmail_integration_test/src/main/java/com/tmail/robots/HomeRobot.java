package com.tmail.robots;

import com.microsoft.playwright.Page;
import com.tmail.base.CoreRobot;

public class HomeRobot extends CoreRobot {

    public HomeRobot(Page page) {
        super(page);
    }

    public void navigateToTestSite(String url) {
        page.navigate(url);
    }
}
