package com.linagora.android.tmail

import android.app.Activity
import android.view.View
import android.view.ViewGroup
import android.webkit.WebView
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Hides the WebView text-selection handles while a Flutter popup menu is shown
 * by dropping the editor's window focus, then restores them afterwards.
 */
class AndroidSelectionHandles(private val activity: Activity) {

    private var suspendedWebView: WebView? = null

    fun register(flutterEngine: FlutterEngine) {
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                SUSPEND_METHOD -> result.success(suspendSelectionHandles())
                RESTORE_METHOD -> result.success(restoreSelectionHandles())
                else -> result.notImplemented()
            }
        }
    }

    private fun suspendSelectionHandles(): Boolean {
        val webView = findTargetWebView(activity.window.decorView) ?: return false
        suspendedWebView = webView
        webView.onWindowFocusChanged(false)
        return true
    }

    private fun restoreSelectionHandles(): Boolean {
        val webView = suspendedWebView?.takeIf { it.isAttachedToWindow }
            ?: findTargetWebView(activity.window.decorView)
            ?: run {
                suspendedWebView = null
                return false
            }

        webView.requestFocus()
        webView.onWindowFocusChanged(true)
        suspendedWebView = null
        return true
    }

    // Returns the focused WebView so we target the active editor, not any other
    // WebView (e.g. an email viewer) that may be visible at the same time.
    private fun findTargetWebView(view: View?): WebView? {
        if (view == null || view.visibility != View.VISIBLE) {
            return null
        }

        if (view is WebView && view.hasFocus()) {
            return view
        }

        return findTargetWebViewInChildren(view)
    }

    private fun findTargetWebViewInChildren(view: View): WebView? {
        if (view !is ViewGroup) {
            return null
        }

        for (index in view.childCount - 1 downTo 0) {
            findTargetWebView(view.getChildAt(index))?.let { return it }
        }

        return null
    }

    private companion object {
        const val CHANNEL = "com.linagora.android.tmail/android_selection_handles"
        const val SUSPEND_METHOD = "suspend"
        const val RESTORE_METHOD = "restore"
    }
}
