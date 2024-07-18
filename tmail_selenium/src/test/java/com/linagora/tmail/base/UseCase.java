package com.linagora.tmail.base;

import com.microsoft.playwright.Page;

public abstract class UseCase {
    public abstract void execute(Page page);

    public TestUtils testUtils = new TestUtils();
}
