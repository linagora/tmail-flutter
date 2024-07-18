package com.linagora.tmail.preprod.oidc.composeEmail;

import org.junit.Test;

import com.linagora.tmail.base.TestBase;
import com.linagora.tmail.usecases.ComposeEmailUseCase;
import com.microsoft.playwright.Browser;
import com.microsoft.playwright.BrowserContext;
import com.microsoft.playwright.Page;

public class ComposeEmailTest extends TestBase {

    public ComposeEmailTest(Browser browser, BrowserContext browserContext, Page page) {
        super(browser, browserContext, page);
    }

    @Test
    public void testComposeEmail() {
        testUseCase(new ComposeEmailUseCase(
                "http://localhost:2023/",
                "firstname100.surname100",
                "secret100",
                "firstname21.surname21"));
    }
}
