package com.tmail.preprod.oidc.composeEmail;

import com.tmail.base.TestBase;
import com.tmail.scenarios.ComposeEmailScenario;

public class ComposeEmailTest extends TestBase {

    ComposeEmailTest() {
        scenario = new ComposeEmailScenario(
                properties.getProperty("app.hostUrl"),
                properties.getProperty("user.name"),
                properties.getProperty("user.password"),
                properties.getProperty("user.additionalMailRecipent"));
    }

}
