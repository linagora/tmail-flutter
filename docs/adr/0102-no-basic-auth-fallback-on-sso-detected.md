# 102. No Basic Auth Fallback When SSO Is Detected

Date: 2026-07-03

## Status

Proposed

## Context

#4667: on a server where SSO (OIDC) was actually advertised, the redirect/token exchange failed and the app silently fell back to the basic-auth form. On an SSO-only server that form can never succeed, trapping the user with a misleading password prompt. It is also a downgrade surface: suppressing webFinger (forcing a 404) would push users to a credential-harvesting basic-auth form.

Root cause: the login flow treated every OIDC failure the same, whether the provider was **confirmed** by webFinger or merely **guessed** from the base URL. Only the guessed case is a legitimate basic-auth fallback.

Key facts:
- `getOIDCConfiguration` is reached two ways: a real webFinger hit (`CheckOIDCIsAvailableSuccess` / `TryGuessingWebFingerSuccess`) or a base-URL guess (`BaseUrlOidcResponse`). The response type is the only signal available at that point.
- Guessing (`generateOidcGuessingUrls`) only probes the user's own domain (`domain`, `autodiscover.domain`, `jmap.domain`), so a webFinger hit is always the user's own infrastructure — there is no cross-domain false-positive to guard against.
- Web OIDC is a full-page redirect: the in-memory config is destroyed and rebuilt from cache to finish the token exchange after the redirect (`_getAuthenticationInfo → _getStoredOidcConfiguration → _getTokenOIDCAction`). So the config must be persisted at discovery time, and a stored config may be an unconfirmed/incomplete one — "presence of a stored config" cannot stand in for the flag.

## Decision

Introduce a single boolean `OIDCConfiguration.ssoConfirmed`, set once in `GetOIDCConfigurationInteractor` as `oidcResponse is! BaseUrlOidcResponse`, and thread it through the failure states (`GetTokenOIDCFailure`, `AuthenticateOidcOnBrowserFailure`).

- **Routing:** `_handleSSORedirectFailure` sends `ssoConfirmed == true` to `LoginFormType.retry` (never basic auth); `false` keeps the existing `_handleCommonOIDCFailure` fallback. This drops the old `featureFailure != null` guard, so the decision now depends on `ssoConfirmed` alone.
- **Messaging:** the `ssoRedirectFailedMessage` banner is gated on the same `ssoConfirmed`, so the guessed-provider path keeps its exception-specific message. A `NetworkException` is further excluded, so an offline/connection drop mid-redirect surfaces the accurate network message instead of blaming the SSO redirect. The inline banner is the single explanation surface — no extra toast is layered on top of it.
- **Persistence:** `ssoConfirmed` is persisted as a nullable Hive field because web must rebuild the config from cache after the redirect. In-memory threading already covers the whole single-session flow (all of mobile, plus web first-login), so the persisted flag drives the retry-vs-basic-auth decision only on web relaunch. Legacy entries read back `null`, deliberately treated as `false` — a base-URL-guess config is also persisted, so `false` is the only safe default, and the fix applies once the user re-authenticates through confirmed SSO.

**Boundary:** only a webFinger 200 carrying OIDC links confirms SSO. Every other outcome — 404, 401, 5xx, timeout, TLS failure, empty-links, proxy/captive-portal HTML — is treated as unconfirmed and may still offer basic auth, because none of them is positive proof of an SSO server.

## Consequences

- Confirmed-SSO failures (redirect error, token error, closed browser, broken authority discovery) stay on the SSO retry flow on both web and mobile, with no basic-auth trap.
- Guessed-provider and transient-discovery failures behave exactly as before.
- One-time, web only: an existing confirmed-SSO web user still sees basic auth once on relaunch, until their next successful discovery rewrites the cache. Mobile re-discovers every session, so it is correct immediately.
- Known limitation (rare, web-only): if a server disables SSO after a config was cached with `ssoConfirmed == true`, web relaunch trusts the stale flag and keeps the user on retry until the cache is rewritten. A future option is to re-run webFinger on web relaunch instead of trusting the cached flag.
- Out of scope: TWP/SaaS (`SignInTwakeWorkplaceFailure`) still routes to `_handleCommonOIDCFailure`, and the web auto-login path (`HomeController`) still reloads the login page rather than surfacing the retry directly.
