package com.tmail.base;

import java.util.Arrays;
import java.util.Properties;
import java.util.stream.Stream;

import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.TestInstance;
import org.junit.jupiter.api.extension.ExtendWith;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.MethodSource;

import com.microsoft.playwright.Browser;
import com.microsoft.playwright.BrowserContext;
import com.microsoft.playwright.BrowserType;
import com.microsoft.playwright.Page;
import com.microsoft.playwright.Playwright;

@ExtendWith(CustomParameterResolver.class)
@TestInstance(TestInstance.Lifecycle.PER_CLASS)
public abstract class TestBase {
    private Playwright playwright;
    private Browser browser;
    private BrowserContext browserContext;
    private Page page;

    protected BaseScenario scenario;
    protected Properties properties;

    private static Boolean runHeadlessTest = true;

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
    void setUpAll() {
        playwright = Playwright.create();
    }

    @BeforeEach
    public void setUp(SupportedPlatform supportedPlatform) {
        browser = switch (supportedPlatform) {
            case CHROME -> playwright.chromium().launch(new BrowserType.LaunchOptions().setHeadless(runHeadlessTest));
            case FIREFOX -> playwright.firefox().launch(new BrowserType.LaunchOptions().setHeadless(runHeadlessTest));
            default -> throw new UnsupportedPlatformException();
        };
        browserContext = browser.newContext();
        page = browserContext.newPage();
    }

    @AfterEach
    public void tearDown() {
        page.close();
        browserContext.close();
        browser.close();
    }

    @AfterAll
    void tearDownAll() {
        playwright.close();
    }

    static Stream<SupportedPlatform> supportedPlatforms() {
        return Arrays.asList(SupportedPlatform.values()).stream();
    }

    @ParameterizedTest
    @MethodSource("supportedPlatforms")
    public void testScenario(SupportedPlatform supportedPlatform) {
        scenario.execute(page);
    }
}
