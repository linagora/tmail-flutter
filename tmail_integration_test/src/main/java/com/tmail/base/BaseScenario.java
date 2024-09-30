package com.tmail.base;

import com.microsoft.playwright.Page;

public abstract class BaseScenario {
    public abstract void execute(Page page);

    public TestUtils testUtils = new TestUtils();
}
