package com.linagora.tmail.preprod.oidc.login;

import org.junit.Test;

import com.linagora.tmail.base.TestBase;
import com.linagora.tmail.usecases.LoginUseCase;
import com.microsoft.playwright.Browser;
import com.microsoft.playwright.BrowserContext;
import com.microsoft.playwright.Page;

public class LoginTest extends TestBase {

    public LoginTest(Browser browser, BrowserContext browserContext, Page page) {
        super(browser, browserContext, page);
    }

    @Test
    public void testLogin() {
        testUseCase(new LoginUseCase(
                "http://localhost:2023/",
                "firstname100.surname100",
                "secret100"));
    }
}
