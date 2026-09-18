# Configuration for Workplace FQDN

## Context
- The **Workplace FQDN** is the host used for the paywall upgrade CTA and the Drive attachment picker.
- It comes from two sources, tried in order:
  1. The OIDC `/userInfo` `workplaceFqdn` claim.
  2. The ecosystem `workplaceFqdnFallback` template.
- The first source with a usable value wins. A later-arriving higher-priority source still takes over.

## How to configure

### 1. OIDC `/userInfo` claim
- The preferred source.
- Set the `workplaceFqdn` claim on the deployment's OIDC `/userInfo` response.
- Nothing to configure in the app.

### 2. Ecosystem fallback template
- Used when `/userInfo` has no `workplaceFqdn` claim, or `/userInfo` is never called (e.g. non-SaaS).
- Add `workplaceFqdnFallback` to the deployment's `.well-known/linagora-ecosystem` document:

```json
{
  "workplaceFqdnFallback": "{localPart}.twake.linagora.com"
}
```

- Supported placeholders: `{localPart}`, `{domainName}` — camelCase only.
- Their URL-encoded forms are also supported: `%7BlocalPart%7D`, `%7BdomainName%7D`.
- `{localPart}` is the signed-in address' local part with dots stripped (`john.doe@corp.tld` → `johndoe`).
- A missing, blank, or unresolvable template is ignored — the app behaves as if no fallback were configured.
- The resolved value must be an `https` host; anything else is discarded.
- A non-`https` value is accepted in debug builds only.

### 3. Verification
- With the claim absent and the template set: the paywall CTA and Drive attachment resolve to the template's host.
- With both present: the `/userInfo` claim is used.
