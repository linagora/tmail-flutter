package com.tmail.preprod.basic_auth.login;

import com.tmail.base.TestBase;
import com.tmail.scenarios.BasicAuthLoginScenario;

public class BasicAuthLoginTest extends TestBase {
    BasicAuthLoginTest() {
        scenario = new BasicAuthLoginScenario(
                properties.getProperty("app.basicAuthUrl"),
                properties.getProperty("user.name"),
                properties.getProperty("user.password"));
    }
}
