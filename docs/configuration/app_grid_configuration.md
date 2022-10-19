## Configuration for App Grid

### Context
- Team Mail is a service inside Twake Workspace which include other services
- User need to access other services from Team Mail

### How to config

1. Add services to configuration file
 
- Each service have the information:
```
    {
      "appName": "Contacts",
      "icon": "ic_contacts_app.svg",
      "appLink": "https://openpaas.linagora.com/contacts/"
    }
```

- All services must be added to the configuration file [configurations\app_dashboard.json](https://github.com/linagora/tmail-flutter/blob/master/configurations/app_dashboard.json)
For example:
```
{
  "apps": [
    {
      "appName": "Twake",
      "icon": "ic_twake_app.svg",
      "appLink": "http://twake.linagora.com/"
    },
    {
      "appName": "App 1",
      "icon": "ic_twake_app.svg",
      "appLink": "http://twake.linagora.com/"  
    },
    ...
  ]
}
```

- `appName`: The name will be showed in App Grid
- `icon`: Name of icon was added in `configurations\icons` folder
- `appLink`: Service URL

2. Enable it in [env.file](https://github.com/linagora/tmail-flutter/blob/master/env.file)
```
APP_GRID_AVAILABLE=supported
```
If you want to disable it, please change the value to `unsupported` or remove this from `env.file`
