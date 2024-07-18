package com.tmail.preprod.oidc.login;

import org.junit.Test;

import com.microsoft.playwright.Browser;
import com.microsoft.playwright.BrowserContext;
import com.microsoft.playwright.Page;
import com.tmail.base.TestBase;
import com.tmail.scenarios.LoginScenario;

public class LoginTest extends TestBase {

    public LoginTest(Browser browser, BrowserContext browserContext, Page page) {
        super(browser, browserContext, page);
    }

    @Test
    public void testLogin() {
        testUseCase(new LoginScenario(
                properties.getProperty("app.hostUrl"),
                properties.getProperty("user.name"),
                properties.getProperty("user.password")));
    }
}
