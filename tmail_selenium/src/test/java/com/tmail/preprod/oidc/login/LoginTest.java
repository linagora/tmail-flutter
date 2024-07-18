package com.tmail.preprod.oidc.login;

import com.tmail.base.TestBase;
import com.tmail.scenarios.LoginScenario;

public class LoginTest extends TestBase {

    LoginTest() {
        scenario = new LoginScenario(
                properties.getProperty("app.hostUrl"),
                properties.getProperty("user.name"),
                properties.getProperty("user.password"));
    }

}
