package com.linagora.tmail.preprod.oidc.composeEmail;

import org.openqa.selenium.By;
import org.openqa.selenium.Keys;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import com.linagora.tmail.base.UseCase;
import com.linagora.tmail.preprod.oidc.login.LoginUseCase;

public class ComposeEmailUseCase extends UseCase {

    @Override
    public void execute(WebDriver webDriver, WebDriverWait wait) {
        LoginUseCase loginUseCase = new LoginUseCase();
        loginUseCase.execute(webDriver, wait);

        By composeButtonSelector = By.cssSelector("flt-semantics[aria-label='Compose']");
        wait.until(ExpectedConditions.visibilityOfElementLocated(composeButtonSelector));
        webDriver.findElement(composeButtonSelector).click();

        By toFieldSelector = By.cssSelector("flt-semantics[aria-label*='Composer:to'] input");
        wait.until(ExpectedConditions.visibilityOfElementLocated(toFieldSelector));
        webDriver.findElement(toFieldSelector).click();
        webDriver.findElement(toFieldSelector).sendKeys("firstname100.surname100");
        By toSuggestionSelector = By.cssSelector("flt-semantics[aria-label*='Composer:suggestion:firstname100']");
        wait.until(ExpectedConditions.visibilityOfElementLocated(toSuggestionSelector));
        webDriver.findElement(toSuggestionSelector).click();
        webDriver.findElement(toFieldSelector).sendKeys(Keys.TAB);

        By subjectFieldSelector = By.cssSelector("input[aria-label*='Composer:subject']");
        wait.until(ExpectedConditions.visibilityOfElementLocated(subjectFieldSelector));
        webDriver.findElement(subjectFieldSelector).sendKeys("Test subject");
        webDriver.findElement(subjectFieldSelector).sendKeys(Keys.TAB);

        webDriver.switchTo().frame(0);
        By editorSelector = By.cssSelector(".note-editable");
        webDriver.findElement(editorSelector).sendKeys("Test content");

        webDriver.switchTo().defaultContent();
        By sendButtonSelector = By.cssSelector("flt-semantics[aria-label='Send']");
        webDriver.findElement(sendButtonSelector).click();

        By sendSuccessfulMessageSelector = By
                .cssSelector("flt-semantics[aria-label='Message has been sent successfully']");
        wait.until(ExpectedConditions.visibilityOfElementLocated(sendSuccessfulMessageSelector));
    }

}
