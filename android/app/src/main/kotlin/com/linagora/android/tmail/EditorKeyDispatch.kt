package com.linagora.android.tmail

import android.view.KeyEvent
import android.view.View
import android.webkit.WebView

object EditorKeyDispatch {
    // Flutter can retain a stale text-field connection after the editor gains focus.
    fun dispatch(focus: View?, event: KeyEvent, superDispatch: (KeyEvent) -> Boolean): Boolean {
        val focusedEditor = (focus as? WebView)?.takeIf { it.onCheckIsTextEditor() }
        if (!event.isSystem && focusedEditor?.dispatchKeyEvent(event) == true) {
            return true
        }
        return superDispatch(event)
    }
}
