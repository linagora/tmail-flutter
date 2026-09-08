## Configuration Drive Attachment

### Context
- The Drive attachment button in the composer (and its toggle in Settings > Preferences) is hidden unless this flag is turned on.
- When turned on, the button still requires a Workplace FQDN from the OIDC user info, the server ecosystem `driveAttachment.enabled` flag, and the user preference toggle.
- Applies to web and mobile builds alike.
### How to config
In [env.file]:
- If you want to show the Drive attachment button:
```DRIVE_ATTACHMENT_ENABLED=true```
- If you don't want to show the Drive attachment button:
```DRIVE_ATTACHMENT_ENABLED=false```
    or
```DRIVE_ATTACHMENT_ENABLED=```
