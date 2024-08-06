package com.tmail.preprod.basic_auth.login;

import static com.tmail.preprod.extension.Fixture.BOB;
import static com.tmail.preprod.extension.Fixture.PASSWORD;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.extension.RegisterExtension;

import com.tmail.base.TestBase;
import com.tmail.preprod.extension.TmailExtension;
import com.tmail.scenarios.BasicAuthLoginScenario;

public class BasicAuthLoginTest extends TestBase {
    @RegisterExtension
    TmailExtension tmailExtension = new TmailExtension();

    @BeforeEach
    void setupScenario() {
        scenario = new BasicAuthLoginScenario(
            tmailExtension.getTmailWebUrl().toString(),
            BOB,
            PASSWORD);
    }
}
