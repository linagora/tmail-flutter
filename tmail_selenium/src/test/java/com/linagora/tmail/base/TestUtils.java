package com.linagora.tmail.base;

import com.microsoft.playwright.Page;

public class TestUtils {
    public void waitFor(int seconds, Page page) {
        page.waitForTimeout(seconds * 1000);
    }
}
