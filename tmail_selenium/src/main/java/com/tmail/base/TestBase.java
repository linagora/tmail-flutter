package com.tmail.base;

import java.util.Arrays;
import java.util.Properties;
import java.util.stream.Stream;

import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.MethodSource;

import com.microsoft.playwright.Browser;
import com.microsoft.playwright.BrowserContext;
import com.microsoft.playwright.BrowserType;
import com.microsoft.playwright.Page;
import com.microsoft.playwright.Playwright;

public abstract class TestBase {
    private static Playwright playwright;
    private static Browser browser;
    private static BrowserContext browserContext;
    private static Page page;

    protected BaseScenario scenario;
    protected Properties properties;

    private Boolean runHeadlessTest = false;

    public TestBase() {
        properties = new Properties();
        ClassLoader loader = getClass().getClassLoader();
        try {
            properties.load(loader.getResourceAsStream("config.properties"));
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @BeforeAll
    static void setUpAll() {
        playwright = Playwright.create();
    }

    @AfterEach
    public void tearDown() {
        page.close();
        browserContext.close();
        browser.close();
    }

    @AfterAll
    static void tearDownAll() {
        playwright.close();
    }

    static Stream<SupportedPlatform> supportedPlatforms() {
        return Arrays.asList(SupportedPlatform.values()).stream();
    }

    @ParameterizedTest
    @MethodSource("supportedPlatforms")
    public void testScenario(SupportedPlatform supportedPlatform) {
        browser = switch (supportedPlatform) {
            case CHROME -> playwright.chromium().launch(new BrowserType.LaunchOptions().setHeadless(runHeadlessTest));
            case FIREFOX -> playwright.firefox().launch(new BrowserType.LaunchOptions().setHeadless(runHeadlessTest));
            default -> throw new UnsupportedPlatformException();
        };
        browserContext = browser.newContext();
        page = browserContext.newPage();
        scenario.execute(page);
    }
}
