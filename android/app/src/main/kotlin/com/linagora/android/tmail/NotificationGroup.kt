package com.linagora.android.tmail

import android.app.NotificationManager
import android.content.Context
import android.os.Build
import android.text.TextUtils
import androidx.core.app.NotificationManagerCompat
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class NotificationGroup {
    private val channel = "com.linagora.android.teammail.notification.group.permission"

    fun register(flutterEngine: FlutterEngine, applicationContext: Context) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setMethodCallHandler { call, result ->
            try {
                if (call.method == "getNotificationGroupPermission") {
                    val groupId = call.arguments
                    if (groupId is String) {
                        val isEnabled = getNotificationChannelGroupStatus(applicationContext, groupId)
                        result.success(isEnabled)
                    } else {
                        result.error("Unavailable", "No such group", "")
                    }
                } else {
                    result.notImplemented()
                }
            } catch (exception: Throwable) {
                result.error("UnknownError", exception.message, "")
            }
        }
    }

    private fun getNotificationChannelGroupStatus(context: Context, groupId: String?): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            if (!TextUtils.isEmpty(groupId)) {
                val manager = context.getSystemService(FlutterFragmentActivity.NOTIFICATION_SERVICE) as NotificationManager
                val group = manager.getNotificationChannelGroup(groupId)
                return !group.isBlocked
            }

            return false
        } else {
            NotificationManagerCompat.from(context).areNotificationsEnabled()
        }
    }
}