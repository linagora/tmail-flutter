package com.linagora.tmail.robots;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import com.linagora.tmail.base.CoreRobot;

public class LoginRobot extends CoreRobot {

    public LoginRobot(WebDriver webDriver, WebDriverWait wait) {
        super(webDriver, wait);
    }

    public void enterUsername(String username) {
        wait.until(ExpectedConditions.visibilityOfElementLocated(By.id("username")));
        webDriver.findElement(By.id("username")).sendKeys(username);
    }

    public void enterPassword(String password) {
        wait.until(ExpectedConditions.visibilityOfElementLocated(By.id("password")));
        webDriver.findElement(By.id("password")).sendKeys(password);
    }

    public void clickLogin() {
        wait.until(ExpectedConditions.visibilityOfElementLocated(By.id("kc-login")));
        webDriver.findElement(By.id("kc-login")).click();
    }

}
