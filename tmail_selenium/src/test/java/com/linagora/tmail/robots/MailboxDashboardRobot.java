package com.linagora.tmail.robots;

import static org.junit.Assert.assertTrue;

import java.util.List;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import com.linagora.tmail.base.CoreRobot;

public class MailboxDashboardRobot extends CoreRobot {

    public MailboxDashboardRobot(WebDriver webDriver, WebDriverWait wait) {
        super(webDriver, wait);
    }

    public void clickSentMailbox() {
        By sentButtonSelector = By.cssSelector("flt-semantics[aria-label='Sent']");
        wait.until(ExpectedConditions.visibilityOfElementLocated(sentButtonSelector));
        webDriver.findElement(sentButtonSelector).click();
    }

    public void checkIfThereAreMoreThanOneEmailSentBy(String username) {
        By emailThreadSelector = By.cssSelector("flt-semantics[aria-label*='" + username + "']");
        wait.until(ExpectedConditions.visibilityOfElementLocated(emailThreadSelector));

        List<WebElement> emailThreads = webDriver.findElements(emailThreadSelector);
        System.out.println(emailThreads.size());
        assertTrue(emailThreads.size() > 1);
    }

    public void openComposer() {
        By composeButtonSelector = By.cssSelector("flt-semantics[aria-label='Compose']");
        wait.until(ExpectedConditions.visibilityOfElementLocated(composeButtonSelector));
        webDriver.findElement(composeButtonSelector).click();
    }

    public void waitForSendEmailSuccessToast() {
        waitUntilExactLabelIsVisible("Message has been sent successfully");
    }

}
