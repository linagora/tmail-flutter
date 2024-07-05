package com.linagora.tmail.base;

import org.openqa.selenium.WebDriver;
import org.openqa.selenium.support.ui.WebDriverWait;

public abstract class UseCase {
    public abstract void execute(WebDriver webDriver, WebDriverWait wait);

    public TestUtils testUtils = new TestUtils();
}
