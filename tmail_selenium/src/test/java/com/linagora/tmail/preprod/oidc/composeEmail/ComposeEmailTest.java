package com.linagora.tmail.preprod.oidc.composeEmail;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.support.ui.WebDriverWait;

import com.linagora.tmail.base.TestBase;

@RunWith(Parameterized.class)
public class ComposeEmailTest extends TestBase {

    public ComposeEmailTest(WebDriver webDriver, WebDriverWait wait) {
        super(webDriver, wait);
    }

    @Test
    public void testComposeEmail() {
        testUseCase(new ComposeEmailUseCase());
    }
}
