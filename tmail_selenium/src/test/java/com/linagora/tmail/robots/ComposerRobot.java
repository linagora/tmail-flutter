package com.linagora.tmail.robots;

import java.util.ArrayList;

import org.openqa.selenium.By;
import org.openqa.selenium.Keys;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import com.linagora.tmail.base.CoreRobot;

public class ComposerRobot extends CoreRobot {

    public ComposerRobot(WebDriver webDriver, WebDriverWait wait) {
        super(webDriver, wait);
    }

    public void addReceipients(ArrayList<String> recipients) {
        By toFieldSelector = By.cssSelector("flt-semantics[aria-label*='Composer:to'] input");
        wait.until(ExpectedConditions.visibilityOfElementLocated(toFieldSelector));
        webDriver.findElement(toFieldSelector).click();
        for (String recipient : recipients) {
            webDriver.findElement(toFieldSelector).sendKeys(recipient);
            By toSuggestionSelector = By
                    .cssSelector("flt-semantics[aria-label*='Composer:suggestion:" + recipient + "']");
            wait.until(ExpectedConditions.visibilityOfElementLocated(toSuggestionSelector));
            webDriver.findElement(toSuggestionSelector).click();
        }
        webDriver.findElement(toFieldSelector).sendKeys(Keys.TAB);
    }

    public void addSubject(String subject) {
        By subjectFieldSelector = By.cssSelector("input[aria-label*='Composer:subject']");
        wait.until(ExpectedConditions.visibilityOfElementLocated(subjectFieldSelector));
        webDriver.findElement(subjectFieldSelector).sendKeys(subject);
        webDriver.findElement(subjectFieldSelector).sendKeys(Keys.TAB);
    }

    public void addContent(String content) {
        webDriver.switchTo().frame(0);
        By editorSelector = By.cssSelector(".note-editable");
        webDriver.findElement(editorSelector).sendKeys(content);
        webDriver.switchTo().defaultContent();
    }

    public void clickSend() {
        By sendButtonSelector = By.cssSelector("flt-semantics[aria-label='Send']");
        wait.until(ExpectedConditions.visibilityOfElementLocated(sendButtonSelector));
        webDriver.findElement(sendButtonSelector).click();
    }

}
