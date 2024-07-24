package com.tmail.preprod.extension;

import static com.tmail.preprod.extension.Fixture.BOB;
import static com.tmail.preprod.extension.Fixture.DOMAIN;
import static com.tmail.preprod.extension.Fixture.PASSWORD;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.net.URI;
import java.net.URL;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.Duration;
import java.util.Optional;
import java.util.UUID;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.junit.jupiter.api.extension.AfterAllCallback;
import org.junit.jupiter.api.extension.AfterEachCallback;
import org.junit.jupiter.api.extension.BeforeAllCallback;
import org.junit.jupiter.api.extension.BeforeEachCallback;
import org.junit.jupiter.api.extension.ExtensionContext;
import org.testcontainers.containers.GenericContainer;
import org.testcontainers.containers.Network;
import org.testcontainers.containers.wait.strategy.LogMessageWaitStrategy;
import org.testcontainers.containers.wait.strategy.Wait;
import org.testcontainers.containers.wait.strategy.WaitStrategy;
import org.testcontainers.utility.MountableFile;

public class TmailExtension implements BeforeAllCallback, BeforeEachCallback, AfterEachCallback, AfterAllCallback {

    public enum IsolationLevel {
        // Do not restart container after each test. Low isolation between tests, but fast pace for test suite.
        // Suitable for either test suite that does not require strong isolation, or you are confident that backend data is well cleaned up each test.
        // Note that in this mode, the TmailExtension already handles clean up some basic data after each test. You may need to clean up additional data yourself if needed.
        LOW,

        // Always restart container after each test. Strong isolation between tests, but slow pace for test suite.
        // Suitable for either test suite that requires strong isolation, or you are NOT confident that backend data is well cleaned up each test.
        // Note that in this mode, you do not need to care about cleaning up data yourself.
        HIGH
    }

    private static final String TMAIL_WEB_LATEST_IMAGE_ENV = "tmail-web-latest-image"; // environment variable stores the docker image tag for the current branch. e.g., can set by CI or local dev
    private static final WaitStrategy WAIT_STRATEGY =  new LogMessageWaitStrategy().withRegEx(".*JAMES server started.*\\n").withTimes(1)
        .withStartupTimeout(Duration.ofMinutes(3));
    private static final int JMAP_PORT = 80;
    private static final int WEB_ADMIN_PORT = 8000;
    private static final int NGINX_HTTP_PORT = 80;
    private static final int TMAIL_WEB_PORT = 80;

    private final IsolationLevel isolationLevel;
    private final GenericContainer<?> tmailBackend;
    private final GenericContainer<?> tmailWeb;
    private final GenericContainer<?> nginx;
    private final HttpClient httpClient;

    public TmailExtension(IsolationLevel isolationLevel) {
        this.isolationLevel = isolationLevel;

        Network network = Network.newNetwork();

        this.tmailBackend = new GenericContainer<>("linagora/tmail-backend:memory-0.10.2")
            .withNetworkAliases("tmail-backend")
            .withNetwork(network)
            .withCopyFileToContainer(MountableFile.forClasspathResource("tmail-backend-conf/imapserver.xml"), "/root/conf/")
            .withCopyFileToContainer(MountableFile.forClasspathResource("tmail-backend-conf/smtpserver.xml"), "/root/conf/")
            .withCopyFileToContainer(MountableFile.forClasspathResource("tmail-backend-conf/jwt_privatekey"), "/root/conf/")
            .withCopyFileToContainer(MountableFile.forClasspathResource("tmail-backend-conf/jwt_publickey"), "/root/conf/")
            .withCopyFileToContainer(MountableFile.forClasspathResource("tmail-backend-conf/jmap.properties"), "/root/conf/")
            .withCreateContainerCmdModifier(createContainerCmd -> createContainerCmd.withName("tmail-backend-memory-testing" + UUID.randomUUID()))
            .waitingFor(WAIT_STRATEGY)
            .withExposedPorts(JMAP_PORT, WEB_ADMIN_PORT);

        this.nginx = new GenericContainer<>("nginx:alpine")
            .withNetwork(network)
            .dependsOn(tmailBackend)
            .withExposedPorts(NGINX_HTTP_PORT)
            .waitingFor(Wait.forHttp("/").forStatusCode(200));

        String tmailWebImageTag = Optional.ofNullable(System.getenv(TMAIL_WEB_LATEST_IMAGE_ENV))
            .orElse("linagora/tmail-web:latest");
        this.tmailWeb = new GenericContainer<>(tmailWebImageTag)
            .withNetworkAliases("tmail-web")
            .withNetwork(network)
            .dependsOn(nginx)
            .withCreateContainerCmdModifier(createContainerCmd -> createContainerCmd.withName("tmail-web-testing" + UUID.randomUUID()))
            .waitingFor(Wait.forHttp("/").forStatusCode(200))
            .withExposedPorts(TMAIL_WEB_PORT);

        this.httpClient = HttpClient.newHttpClient();
    }

    public TmailExtension() {
        this(IsolationLevel.LOW);
    }

    @Override
    public void beforeAll(ExtensionContext context) {
        if (isolationLevel == IsolationLevel.LOW) {
            startContainers();
        }
    }

    @Override
    public void beforeEach(ExtensionContext extensionContext) throws Exception {
        if (isolationLevel == IsolationLevel.LOW) {
            provisionBackendData();
        }
        if (isolationLevel.equals(IsolationLevel.HIGH)) {
            startContainers();
            provisionBackendData();
        }
    }

    @Override
    public void afterEach(ExtensionContext extensionContext) throws Exception {
        if (isolationLevel == IsolationLevel.LOW) {
            cleanupBackendData();
        }
        if (isolationLevel.equals(IsolationLevel.HIGH)) {
            stopContainers();
        }
    }

    @Override
    public void afterAll(ExtensionContext context) {
        stopContainers();
    }

    private void startContainers() {
        tmailBackend.start();

        // we configure NGINX to tell tmail-backend how to response apiURL during runtime (as apiURL would be dynamic because of TestContainer random port nature)
        nginx.start();
        configureNginxProxyForJmap();

        setupTmailWebEnvFile();
        tmailWeb.start();
    }

    private void stopContainers() {
        Runnables.runParallel(
            tmailBackend::stop,
            nginx::stop,
            tmailWeb::stop);
    }

    private void configureNginxProxyForJmap() {
        try {
            // Create a temporary file for the updated nginx.conf
            Path tempNginxConf = Files.createTempFile("nginx", ".conf");

            // Write the updated nginx configuration to the temporary file
            Files.write(tempNginxConf, ("""
                events {
                    worker_connections 1024;
                }

                http {
                    upstream tmail-backend {
                        server tmail-backend:80;
                    }

                    server {
                        listen 80;

                        location / {
                            proxy_pass http://tmail-backend;
                            proxy_set_header X-JMAP-PREFIX %s;
                            proxy_set_header Host $host;
                        }
                    }
                }
            """.formatted(getProxiedJmapUrl())).getBytes());

            // Copy the updated nginx.conf to the running container
            nginx.copyFileToContainer(MountableFile.forHostPath(tempNginxConf), "/tmp/nginx.conf");

            // Move the updated configuration to the nginx configuration directory
            nginx.execInContainer("mv", "/tmp/nginx.conf", "/etc/nginx/nginx.conf");

            // Reload nginx configuration
            nginx.execInContainer("nginx", "-s", "reload");
        } catch (Exception e) {
            throw new RuntimeException("Failed to create or copy temporary env.file", e);
        }
    }

    private void setupTmailWebEnvFile() {
        try {
            // Create a temporary file with the desired content
            File tempFile = File.createTempFile("env", ".file");
            try (FileWriter writer = new FileWriter(tempFile)) {
                writer.write("SERVER_URL=" + getProxiedJmapUrl() + "\n");
                writer.write("DOMAIN_REDIRECT_URL=http://localhost:3000\n");
            }

            // Copy the temporary file into the container
            tmailWeb.withCopyFileToContainer(MountableFile.forHostPath(tempFile.getAbsolutePath()), "/usr/share/nginx/html/assets/env.file");
        } catch (IOException e) {
            throw new RuntimeException("Failed to create or copy temporary env.file", e);
        }
    }

    public URL getTmailWebUrl() {
        try {
            return new URI("http://" +
                tmailWeb.getHost() + ":" +
                tmailWeb.getMappedPort(TMAIL_WEB_PORT)).toURL();
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    private URL getProxiedJmapUrl() {
        try {
            return new URI("http://" +
                nginx.getHost() + ":" +
                nginx.getMappedPort(NGINX_HTTP_PORT)).toURL();
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    private void provisionBackendData() throws Exception {
        createDomain(DOMAIN);
        createUser(BOB, PASSWORD);
    }

    public void createDomain(String domain) throws Exception {
        tmailBackend.execInContainer("james-cli", "AddDomain", domain);
    }

    public void createUser(String username, String password) throws IOException, InterruptedException {
        tmailBackend.execInContainer("james-cli", "AddUser", username, password);
    }

    private void cleanupBackendData() throws Exception {
        deleteUser(BOB);
        deleteDomain(DOMAIN);
    }

    public void deleteDomain(String domain) throws Exception {
        deleteUsersDataOfDomain(domain);
        tmailBackend.execInContainer("james-cli", "RemoveDomain", domain);
    }

    public void deleteUser(String username) throws Exception {
        deleteUserData(username);
        tmailBackend.execInContainer("james-cli", "RemoveUser", username);
    }

    private URL getTMailBackendWebadminUrl() {
        try {
            return new URI("http://" +
                tmailBackend.getHost() + ":" +
                tmailBackend.getMappedPort(WEB_ADMIN_PORT)).toURL();
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    private void deleteUserData(String username) throws Exception {
        String deleteUserDataUrl = getTMailBackendWebadminUrl() + "/users/"  + username + "?action=deleteData";

        HttpRequest request = HttpRequest.newBuilder()
            .uri(new URI(deleteUserDataUrl))
            .POST(HttpRequest.BodyPublishers.noBody())
            .build();

        HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());

        if (response.statusCode() != 201) {
            throw new RuntimeException("Failed to delete user data for username: " + username);
        }

        // Extract taskId from response body
        Pattern pattern = Pattern.compile("\"taskId\":\"([^\"]+)\"");
        Matcher matcher = pattern.matcher(response.body());
        if (matcher.find()) {
            String taskId = matcher.group(1);
            awaitTaskCompletion(taskId);
        } else {
            throw new RuntimeException("Failed to extract taskId from response for username: " + username);
        }
    }

    private void deleteUsersDataOfDomain(String domain) throws Exception {
        String deleteUsersDataOfDomainUrl = getTMailBackendWebadminUrl() + "/domains/"  + domain + "?action=deleteData";

        HttpRequest request = HttpRequest.newBuilder()
            .uri(new URI(deleteUsersDataOfDomainUrl))
            .POST(HttpRequest.BodyPublishers.noBody())
            .build();

        HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());

        if (response.statusCode() != 201) {
            throw new RuntimeException("Failed to delete user data for domain: " + domain);
        }

        // Extract taskId from response body
        Pattern pattern = Pattern.compile("\"taskId\":\"([^\"]+)\"");
        Matcher matcher = pattern.matcher(response.body());
        if (matcher.find()) {
            String taskId = matcher.group(1);
            awaitTaskCompletion(taskId);
        } else {
            throw new RuntimeException("Failed to extract taskId from response for domain: " + domain);
        }
    }

    private void awaitTaskCompletion(String taskId) throws Exception {
        String taskStatusUrl = getTMailBackendWebadminUrl() + "/tasks/" + taskId + "/await";
        HttpRequest request = HttpRequest.newBuilder()
            .uri(new URI(taskStatusUrl))
            .GET()
            .build();

        HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());

        if (response.statusCode() != 200) {
            throw new RuntimeException("Failed to get task status for taskId: " + taskId);
        }
    }
}
