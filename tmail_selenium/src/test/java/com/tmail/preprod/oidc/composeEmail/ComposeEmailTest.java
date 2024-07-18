package com.tmail.preprod.oidc.composeEmail;

import org.junit.Test;

import com.microsoft.playwright.Browser;
import com.microsoft.playwright.BrowserContext;
import com.microsoft.playwright.Page;
import com.tmail.base.TestBase;
import com.tmail.scenarios.ComposeEmailScenario;

public class ComposeEmailTest extends TestBase {

    public ComposeEmailTest(Browser browser, BrowserContext browserContext, Page page) {
        super(browser, browserContext, page);
    }

    @Test
    public void testComposeEmail() {
        testUseCase(new ComposeEmailScenario(
                properties.getProperty("app.hostUrl"),
                properties.getProperty("user.name"),
                properties.getProperty("user.password"),
                properties.getProperty("user.additionalMailRecipent")));
    }
}
