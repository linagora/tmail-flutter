# 61. Cozy integration set up

Date: 2025-04-21

## Status

Accepted

## Context

- How to run Cozy locally?

## Steps
### Install cozy-stack CLI

1. Install CouchDB
```bash
docker run -d \
    --name cozy-stack-couch \
    -p 5984:5984 \
    -e COUCHDB_USER=admin -e COUCHDB_PASSWORD=password \
    -v $HOME/.cozy-stack-couch:/opt/couchdb/data \
    couchdb:3.3
curl -X PUT http://admin:password@127.0.0.1:5984/{_users,_replicator}
```
2. Install cozy-stack CLI
- Install Go and add to path
- Clone cozy-stack
```bash
git clone git@github.com:cozy/cozy-stack.git
cd cozy-stack
make
```
- Create cozy configuration file
```bash
mkdir -p ~/.cozy
cp cozy.example.yaml $HOME/.cozy/cozy.yml
```
- Find CouchDB config inside `cozy.yml` and edit as follow:
```yaml
couchdb:
  url: <http://admin:password@localhost:5984/>
```
3. Run cozy-stack
- Start cozy-stack
```bash
cozy-stack serve
```
- Create an instance
```bash
cozy-stack instances add tmail.localhost:8080 --passphrase cozy --apps home,store,drive,photos,settings,contacts,notes,passwords --email tmail@cozy.localhost --locale en --public-name Tmail --context-name dev
```
- The created instance will be available at http://tmail.localhost:8080/
- The password is `cozy`

### Run Cozy locally
1. On the cozy-twakemail side
- Clone `https://github.com/cozy/cozy-twakemail`
- `yarn install`
- In `src/components/AppLayout.jsx`, replace `flag('mail.embedded-app-url')` with `http://localhost:2023`
- `yarn build`
- `cozy-stack serve --appdir tmail:build/ --disable-csp`

2. On the tmail side
- Config tmail to run on basic auth
- isInsideCozy will be `false` if run on localhost, so in cozy_config_web.dart, return true on isInsideCozy
- in `env.file`, COZY_INTEGRATION=true
- `flutter run -d chrome --web-port 2023 --web-browser-flag "--disable-web-security" --profile`

3. Access Cozy
- tmail cozy: http://tmail.localhost:8080/
- The password is `cozy`