/// Non-web builds have no iframes, so no message comes from one.
bool isMessageFromIframe(Object event, Object? iframe) => false;
