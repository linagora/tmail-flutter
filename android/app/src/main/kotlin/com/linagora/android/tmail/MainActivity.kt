package com.linagora.android.tmail

import android.app.NotificationManager
import android.content.Context
import android.os.Bundle
import android.os.PersistableBundle
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import android.content.Intent.FLAG_ACTIVITY_NEW_TASK
import android.os.Build
import android.text.TextUtils
import androidx.core.app.NotificationManagerCompat
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterFragmentActivity() {

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
    }
}