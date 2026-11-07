## Configuration Cozy Integration

### Context
- Cozy script load is optional
### How to config
In [env.file]:
- If you want to load Cozy script:
```COZY_INTEGRATION=true```
- If you don't want to load Cozy script:
```COZY_INTEGRATION=false```
    or
```COZY_INTEGRATION=```

On web, an embedded app also needs `CSP_FRAME_ANCESTORS`, `CSP_FRAME_SRC` and `CSP_SCRIPT_SRC`
on the web container: see [Content Security Policy](csp_configuration.md).