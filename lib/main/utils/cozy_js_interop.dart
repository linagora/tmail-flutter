import 'dart:js_interop';

@JS('window._cozyBridge.getContacts')
external JSPromise<JSAny?> getContactsJs();

@JS('window._cozyBridge.getFlag')
external JSPromise<JSAny?> getFlagJs(String flagName);

@JS('JSON.stringify')
external String stringify(JSAny? value);