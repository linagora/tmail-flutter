package com.linagora.tmail.preprod.oidc.login;

import org.junit.Test;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.support.ui.WebDriverWait;

import com.linagora.tmail.base.TestBase;
import com.linagora.tmail.usecases.LoginUseCase;

public class LoginTest extends TestBase {

    public LoginTest(WebDriver webDriver, WebDriverWait wait) {
        super(webDriver, wait);
    }

    @Test
    public void testLogin() {
        testUseCase(new LoginUseCase(
                "http://localhost:2023/",
                "firstname100.surname100",
                "secret100"));
    }
}
