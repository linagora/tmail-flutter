package com.linagora.tmail.base;

import java.util.Arrays;
import java.util.Collection;

import org.junit.After;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;

import com.microsoft.playwright.Browser;
import com.microsoft.playwright.BrowserContext;
import com.microsoft.playwright.BrowserType;
import com.microsoft.playwright.Page;
import com.microsoft.playwright.Playwright;

@RunWith(Parameterized.class)
public abstract class TestBase {
    private static Playwright playwright = Playwright.create();
    private Browser browser;
    private BrowserContext browserContext;
    private Page page;

    public TestBase(Browser browser, BrowserContext browserContext, Page page) {
        this.browser = browser;
        this.browserContext = browserContext;
        this.page = page;
    }

    @Parameterized.Parameters
    public static Collection<Object[]> data() {
        Boolean runHeadlessTest = false;
        int size = SupportedPlatform.values().length;
        Object[][] parameters = new Object[size][2];
        for (int i = 0; i < size; i++) {
            SupportedPlatform platform = SupportedPlatform.values()[i];
            Object[] config = new Object[2];
            switch (platform) {
                case CHROME:
                    config = configTestForChrome(runHeadlessTest);
                    break;
                case FIREFOX:
                    config = configTestForFirefox(runHeadlessTest);
                    break;
                default:
                    throw new UnsupportedPlatformException();
            }
            parameters[i] = config;
        }

        return Arrays.asList(parameters);
    }

    public void testUseCase(UseCase useCase) {
        useCase.execute(page);
    }

    private static Object[] configTestForChrome(Boolean headless) {
        Browser browser = playwright.chromium().launch(new BrowserType.LaunchOptions().setHeadless(headless));
        BrowserContext browserContext = browser.newContext();
        Page page = browserContext.newPage();
        Object[] config = new Object[3];
        config[0] = browser;
        config[1] = browserContext;
        config[2] = page;
        return config;
    }

    private static Object[] configTestForFirefox(Boolean headless) {
        Browser browser = playwright.firefox().launch(new BrowserType.LaunchOptions().setHeadless(headless));
        BrowserContext browserContext = browser.newContext();
        Page page = browserContext.newPage();
        Object[] config = new Object[3];
        config[0] = browser;
        config[1] = browserContext;
        config[2] = page;
        return config;
    }

    private void dispose() {
        page.close();
        browserContext.close();
        browser.close();
    }

    @After
    public void tearDown() {
        dispose();
    }
}
