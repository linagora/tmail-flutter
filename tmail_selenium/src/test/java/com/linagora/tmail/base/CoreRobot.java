package com.linagora.tmail.base;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

public abstract class CoreRobot {
    protected WebDriver webDriver;
    protected WebDriverWait wait;

    public CoreRobot(WebDriver webDriver, WebDriverWait wait) {
        this.webDriver = webDriver;
        this.wait = wait;
    }

    public void waitUntilExactLabelIsVisible(String label) {
        By labelSelector = By.cssSelector("flt-semantics[aria-label='" + label + "']");
        wait.until(ExpectedConditions.visibilityOfElementLocated(labelSelector));
    }
}
