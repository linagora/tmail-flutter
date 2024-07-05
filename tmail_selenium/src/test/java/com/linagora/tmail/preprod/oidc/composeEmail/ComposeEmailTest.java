package com.linagora.tmail.preprod.oidc.composeEmail;

import org.junit.Test;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.support.ui.WebDriverWait;

import com.linagora.tmail.base.TestBase;
import com.linagora.tmail.usecases.ComposeEmailUseCase;

public class ComposeEmailTest extends TestBase {

    public ComposeEmailTest(WebDriver webDriver, WebDriverWait wait) {
        super(webDriver, wait);
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
