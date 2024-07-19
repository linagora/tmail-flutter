package com.tmail.preprod.oidc.login;

import com.tmail.base.TestBase;
import com.tmail.scenarios.OidcLoginScenario;

public class OidcLoginTest extends TestBase {

    OidcLoginTest() {
        scenario = new OidcLoginScenario(
                properties.getProperty("app.hostUrl"),
                properties.getProperty("user.name"),
                properties.getProperty("user.password"));
    }

}
