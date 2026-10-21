package com.linagora.android.tmail;

import android.content.Context;
import android.os.SystemClock;
import android.view.InputDevice;
import android.view.KeyEvent;
import android.view.ViewGroup;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.EditText;
import android.widget.FrameLayout;
import androidx.test.core.app.ActivityScenario;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicReference;
import static org.junit.Assert.*;

public class WebViewKeyboardTest {
    private static final long TIMEOUT_MILLIS = 5000;
    private static final String EDITOR_HTML = "<div id=\"editor\" contenteditable=\"true\"></div>";
    private static final String EDITOR = "document.getElementById('editor')";
    private static final String EDITOR_TEXT = EDITOR + ".textContent";

    private ActivityScenario<MainActivity> scenario;
    private KeyConsumingLayout parent;
    private WebView webView;

    @Before
    public void setUp() {
        scenario = ActivityScenario.launch(MainActivity.class);
        scenario.onActivity(activity -> {
            parent = new KeyConsumingLayout(activity);
            activity.setContentView(parent);
        });
    }

    @After
    public void tearDown() {
        scenario.onActivity(activity -> {
            parent.removeAllViews();
            if (webView != null) webView.destroy();
        });
        scenario.close();
    }

    @Test
    public void editorReceivesCharactersBeforeAnAncestorCanConsumeThem() {
        assertWebViewCase(true,
            new KeyEvent(KeyEvent.ACTION_DOWN, KeyEvent.KEYCODE_A),
            new KeyEvent(KeyEvent.ACTION_UP, KeyEvent.KEYCODE_A));
    }

    @Test
    public void realEditorInsertsCharactersBeforeAnAncestorCanConsumeThem() throws InterruptedException {
        WebView editor = loadEditor();
        evaluate(editor, EDITOR + ".focus()");
        awaitTextEditor(editor);

        scenario.onActivity(activity -> {
            activity.dispatchKeyEvent(new KeyEvent(KeyEvent.ACTION_DOWN, KeyEvent.KEYCODE_A));
            activity.dispatchKeyEvent(new KeyEvent(KeyEvent.ACTION_UP, KeyEvent.KEYCODE_A));
        });

        assertEquals("\"a\"", awaitEditorText(editor, "\"a\""));
    }

    @Test
    public void nonWebViewFocusKeepsNormalActivityDispatch() {
        scenario.onActivity(activity -> {
            focus(new EditText(activity));
            parent.consumeAll = true;
            assertDispatchedTo(activity, parent.events, new KeyEvent(KeyEvent.ACTION_DOWN, KeyEvent.KEYCODE_A));
        });
    }

    @Test
    public void nonEditableWebViewKeepsNormalActivityDispatch() {
        scenario.onActivity(activity -> {
            RecordingWebView viewer = focusEditor(activity, true);
            viewer.editable = false;
            parent.consumeAll = true;
            assertDispatchedTo(activity, parent.events, new KeyEvent(KeyEvent.ACTION_DOWN, KeyEvent.KEYCODE_DPAD_DOWN));
            assertEquals(0, viewer.events.size());
        });
    }

    @Test
    public void webViewReceivesOriginalModifiersRepeatsAndKeyUp() {
        long now = SystemClock.uptimeMillis();
        assertWebViewCase(true,
            new KeyEvent(now, now, KeyEvent.ACTION_DOWN, KeyEvent.KEYCODE_DPAD_LEFT,
                3, KeyEvent.META_CTRL_ON | KeyEvent.META_SHIFT_ON, -1, 0, 0, InputDevice.SOURCE_KEYBOARD),
            new KeyEvent(KeyEvent.ACTION_UP, KeyEvent.KEYCODE_DPAD_LEFT));
    }

    @Test
    public void unhandledWebViewKeysFallBackToActivityDispatch() {
        assertWebViewCase(false, new KeyEvent(KeyEvent.ACTION_DOWN, KeyEvent.KEYCODE_A));
    }

    @Test
    public void backAndVolumeKeysKeepSystemDispatch() {
        scenario.onActivity(activity -> {
            RecordingWebView editor = focusEditor(activity, true);
            parent.consumeAll = true;
            for (int code : new int[]{KeyEvent.KEYCODE_BACK, KeyEvent.KEYCODE_VOLUME_UP}) {
                assertTrue(activity.dispatchKeyEvent(new KeyEvent(KeyEvent.ACTION_DOWN, code)));
            }
            assertEquals(2, parent.events.size());
            assertEquals(0, editor.events.size());
        });
    }

    private void assertWebViewCase(boolean handled, KeyEvent... events) {
        scenario.onActivity(activity -> {
            RecordingWebView editor = focusEditor(activity, handled);
            assertDispatchedTo(activity, editor.events, events);
            assertEquals(handled ? 0 : events.length, parent.events.size());
        });
    }

    private RecordingWebView focusEditor(MainActivity activity, boolean handled) {
        RecordingWebView editor = new RecordingWebView(activity, handled);
        webView = editor;
        focus(editor);
        return editor;
    }

    private WebView loadEditor() throws InterruptedException {
        CountDownLatch loaded = new CountDownLatch(1);
        scenario.onActivity(activity -> {
            webView = new WebView(activity);
            webView.getSettings().setJavaScriptEnabled(true);
            webView.setWebViewClient(new WebViewClient() {
                @Override
                public void onPageFinished(WebView view, String url) { loaded.countDown(); }
            });
            webView.loadData(EDITOR_HTML, "text/html", "utf-8");
            focus(webView);
        });
        assertTrue(loaded.await(TIMEOUT_MILLIS, TimeUnit.MILLISECONDS));
        return webView;
    }

    private String evaluate(WebView editor, String script) throws InterruptedException {
        CountDownLatch evaluated = new CountDownLatch(1);
        AtomicReference<String> result = new AtomicReference<>();
        scenario.onActivity(activity -> editor.evaluateJavascript(script, value -> {
            result.set(value);
            evaluated.countDown();
        }));
        assertTrue(evaluated.await(TIMEOUT_MILLIS, TimeUnit.MILLISECONDS));
        return result.get();
    }

    // Chromium reports the focused editable asynchronously, as it does after a tap on the body.
    private void awaitTextEditor(WebView editor) {
        long deadline = SystemClock.uptimeMillis() + TIMEOUT_MILLIS;
        AtomicBoolean ready = new AtomicBoolean();
        while (!ready.get() && SystemClock.uptimeMillis() < deadline) {
            scenario.onActivity(activity -> ready.set(editor.onCheckIsTextEditor()));
        }
        assertTrue(ready.get());
    }

    // Chromium inserts the character asynchronously, so poll the DOM until it matches or times out.
    private String awaitEditorText(WebView editor, String expected) throws InterruptedException {
        long deadline = SystemClock.uptimeMillis() + TIMEOUT_MILLIS;
        String text = evaluate(editor, EDITOR_TEXT);
        while (!expected.equals(text) && SystemClock.uptimeMillis() < deadline) {
            text = evaluate(editor, EDITOR_TEXT);
        }
        return text;
    }

    private static void assertDispatchedTo(MainActivity activity, List<KeyEvent> recorded, KeyEvent... events) {
        for (KeyEvent event : events) assertTrue(activity.dispatchKeyEvent(event));
        assertEquals(events.length, recorded.size());
        for (int i = 0; i < events.length; i++) assertSame(events[i], recorded.get(i));
    }

    private void focus(android.view.View view) {
        parent.addView(view, new FrameLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        view.setFocusableInTouchMode(true);
        assertTrue(view.requestFocus());
    }

    private static class KeyConsumingLayout extends FrameLayout {
        final List<KeyEvent> events = new ArrayList<>();
        boolean consumeAll;

        KeyConsumingLayout(Context context) { super(context); }

        @Override
        public boolean dispatchKeyEvent(KeyEvent event) {
            events.add(event);
            if (consumeAll || isCharacterKeyDown(event)) return true;
            return super.dispatchKeyEvent(event);
        }

        // Models Flutter's stale adaptor: it consumes character key-downs only.
        private static boolean isCharacterKeyDown(KeyEvent event) {
            return event.getAction() == KeyEvent.ACTION_DOWN && event.getUnicodeChar() != 0;
        }
    }

    private static class RecordingWebView extends WebView {
        final List<KeyEvent> events = new ArrayList<>();
        final boolean handled;
        boolean editable = true;

        RecordingWebView(Context context, boolean handled) {
            super(context);
            this.handled = handled;
        }

        @Override
        public boolean onCheckIsTextEditor() { return editable; }

        @Override
        public boolean dispatchKeyEvent(KeyEvent event) {
            events.add(event);
            return handled;
        }
    }
}
