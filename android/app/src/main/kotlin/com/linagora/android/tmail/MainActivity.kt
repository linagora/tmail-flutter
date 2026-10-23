package com.linagora.android.tmail

import android.annotation.SuppressLint
import android.os.Bundle
import android.os.PersistableBundle
import android.view.KeyEvent
import android.webkit.WebView
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import android.content.Intent.FLAG_ACTIVITY_NEW_TASK

class MainActivity: FlutterFragmentActivity() {

    @SuppressLint("RestrictedApi") // AndroidX restricts the inherited public Activity callback.
    override fun dispatchKeyEvent(event: KeyEvent): Boolean {
        val focusedEditor = (currentFocus as? WebView)?.takeIf { it.onCheckIsTextEditor() }
        // Flutter can retain a stale text-field connection after the editor gains focus.
        if (!event.isSystem && focusedEditor?.dispatchKeyEvent(event) == true) {
            return true
        }
        return super.dispatchKeyEvent(event)
    }

    override fun onCreate(savedInstanceState: Bundle?, persistentState: PersistableBundle?) {
        if (intent.getIntExtra("org.chromium.chrome.extra.TASK_ID", -1) == this.taskId) {
            this.finish()
            intent.addFlags(FLAG_ACTIVITY_NEW_TASK);
            startActivity(intent);
        }
        super.onCreate(savedInstanceState, persistentState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)

        NotificationGroup().register(flutterEngine, applicationContext)
        AndroidSelectionHandles(this).register(flutterEngine)
    }
}
