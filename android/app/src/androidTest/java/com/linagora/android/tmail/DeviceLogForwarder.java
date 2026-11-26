package com.linagora.android.tmail;

import android.app.UiAutomation;
import android.os.Bundle;
import android.os.ParcelFileDescriptor;
import android.util.Log;
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;

// FTL drops logcat of attempts that crash the device, so stream it to the CI host.
final class DeviceLogForwarder {
    private static final String TAG = "DeviceLogForwarder";
    private static final long FLUSH_MS = 500;
    private static final int MAX_BATCH_CHARS = 512 * 1024;
    private static final Object LOCK = new Object();
    private static final StringBuilder BUFFER = new StringBuilder();
    private static volatile boolean running;
    private static ParcelFileDescriptor pipe;
    private static Thread sender;
    private static String endpoint;
    private static String shard;
    private static String bootId;

    private DeviceLogForwarder() {}

    static void start(UiAutomation automation, Bundle args) {
        String base = args.getString("resetServerUrl", "");
        if (base.isEmpty() || running) return;
        endpoint = base + "/devlog";
        shard = args.getString("shardIndex", "0");
        bootId = readBootId();
        running = true;
        // -T 2000 replays the orchestrator gap before this instrumentation.
        pipe = automation.executeShellCommand("logcat -v threadtime -T 2000 *:I");
        Thread reader = new Thread(DeviceLogForwarder::readLoop, TAG + "-reader");
        reader.setDaemon(true);
        reader.start();
        sender = new Thread(DeviceLogForwarder::sendLoop, TAG + "-sender");
        sender.setDaemon(true);
        sender.start();
    }

    static void stop() {
        if (!running) return;
        running = false;
        try {
            sender.join(3000);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        flush();
        try {
            pipe.close();
        } catch (IOException e) {
            Log.w(TAG, "close failed", e);
        }
    }

    private static void readLoop() {
        try (BufferedReader in = new BufferedReader(new InputStreamReader(
                new ParcelFileDescriptor.AutoCloseInputStream(pipe), StandardCharsets.UTF_8))) {
            String line;
            while (running && (line = in.readLine()) != null) {
                synchronized (LOCK) {
                    if (BUFFER.length() < MAX_BATCH_CHARS) BUFFER.append(line).append('\n');
                }
            }
        } catch (IOException e) {
            Log.w(TAG, "logcat read failed", e);
        }
    }

    private static void sendLoop() {
        while (running) {
            try {
                Thread.sleep(FLUSH_MS);
            } catch (InterruptedException e) {
                return;
            }
            flush();
        }
    }

    private static void flush() {
        String batch;
        synchronized (LOCK) {
            if (BUFFER.length() == 0) return;
            batch = BUFFER.toString();
            BUFFER.setLength(0);
        }
        HttpURLConnection conn = null;
        try {
            conn = (HttpURLConnection) new URL(endpoint).openConnection();
            conn.setConnectTimeout(5000);
            conn.setReadTimeout(5000);
            conn.setDoOutput(true);
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type", "text/plain; charset=utf-8");
            conn.setRequestProperty("X-Shard", shard);
            conn.setRequestProperty("X-Boot-Id", bootId);
            try (OutputStream out = conn.getOutputStream()) {
                out.write(batch.getBytes(StandardCharsets.UTF_8));
            }
            conn.getResponseCode();
        } catch (IOException | RuntimeException e) {
            // Diagnostics only; a lost batch must never fail a test.
            Log.w(TAG, "devlog post failed: " + e);
        } finally {
            if (conn != null) conn.disconnect();
        }
    }

    private static String readBootId() {
        try (BufferedReader in = new BufferedReader(new FileReader("/proc/sys/kernel/random/boot_id"))) {
            String id = in.readLine();
            return id == null ? "unknown" : id.trim();
        } catch (IOException e) {
            return "unknown";
        }
    }
}
