package com.linagora.android.tmail

import android.app.Activity
import android.view.KeyEvent

// Debug-only host for WebViewKeyboardTest: no Flutter engine, no Patrol bundle.
class KeyboardTestActivity : Activity() {
    override fun dispatchKeyEvent(event: KeyEvent): Boolean =
        EditorKeyDispatch.dispatch(currentFocus, event) { super.dispatchKeyEvent(it) }
}
