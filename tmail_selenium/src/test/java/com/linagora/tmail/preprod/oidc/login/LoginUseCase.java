package com.linagora.tmail.preprod.oidc.login;

import static org.junit.Assert.assertTrue;

import java.util.List;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import com.linagora.tmail.base.UseCase;

public class LoginUseCase extends UseCase {

    @Override
    public void execute(WebDriver webDriver, WebDriverWait wait) {
        webDriver.navigate().to("http://localhost:2023/");

        wait.until(ExpectedConditions.visibilityOfElementLocated(By.id("username")));

        webDriver.findElement(By.id("username")).sendKeys("firstname100.surname100");
        webDriver.findElement(By.id("password")).sendKeys("secret100");
        webDriver.findElement(By.id("kc-login")).click();

        By composeButtonSelector = By.cssSelector("flt-semantics[aria-label='Compose']");
        wait.until(ExpectedConditions.visibilityOfElementLocated(composeButtonSelector));

        testUtils.waitFor(2);

        By sentButtonSelector = By.cssSelector("flt-semantics[aria-label='Sent']");
        wait.until(ExpectedConditions.visibilityOfElementLocated(sentButtonSelector));
        webDriver.findElement(sentButtonSelector).click();

        testUtils.waitFor(2);

        By emailThreadSelector = By.cssSelector("flt-semantics[aria-label*='firstname100.surname100']");
        wait.until(ExpectedConditions.visibilityOfElementLocated(emailThreadSelector));

        List<WebElement> emailThreads = webDriver.findElements(emailThreadSelector);
        System.out.println(emailThreads.size());
        assertTrue(emailThreads.size() > 1);
    }

}
