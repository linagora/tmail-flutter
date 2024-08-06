package com.tmail.base;

import com.microsoft.playwright.Page;

public abstract class CoreRobot {
    protected Page page;

    public CoreRobot(Page page) {
        this.page = page;
    }
}
