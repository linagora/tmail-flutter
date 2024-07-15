package com.linagora.tmail.preprod.oidc.login;

import static org.junit.Assert.assertTrue;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import com.microsoft.playwright.Browser;
import com.microsoft.playwright.BrowserContext;
import com.microsoft.playwright.BrowserType;
import com.microsoft.playwright.Page;
import com.microsoft.playwright.Page.WaitForSelectorOptions;
import com.microsoft.playwright.Playwright;
import com.microsoft.playwright.options.WaitForSelectorState;

public class PlaywrightLoginTest {
    Playwright playwright;
    Browser browser;
    BrowserContext context;
    Page page;

    @Before
    public void setup() {
        playwright = Playwright.create();
        browser = playwright.chromium().launch(new BrowserType.LaunchOptions().setHeadless(false));
        context = browser.newContext();
        page = context.newPage();
    }

    @After
    public void tearDown() {
        context.close();
        playwright.close();
    }

    @Test
    public void login() {
        page.navigate("http://localhost:2023/");
        page.locator("#username").fill("firstname100.surname100");
        page.locator("#password").fill("secret100");
        page.locator("#kc-login").click();
        page.locator("flt-semantics[aria-label='Sent']").waitFor();
        page.locator("flt-semantics[aria-label='Sent']").click();
        page.waitForTimeout(1000);
        page.waitForSelector(
                "flt-semantics[aria-label*='firstname100.surname100']",
                new WaitForSelectorOptions().setState(WaitForSelectorState.VISIBLE));
        assertTrue(page.locator("flt-semantics[aria-label*='firstname100.surname100']").all().size() > 1);
    }
}
