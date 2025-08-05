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
- `yarn build`
- `cozy-stack serve --appdir tmail:build/ --disable-csp`
- Open another terminal while cozy-stack is running
- `cozy-stack apps install dataproxy --domain tmail.localhost:8080`
- `cozy-stack feature flags --domain tmail.localhost:8080 '{"cozy.search.enabled": true}'`
- `cozy-stack feature flags --domain tmail.localhost:8080 '{"mail.embedded-app-url": "http://localhost:2023"}'`

2. On the tmail side
- Apply patchs/cozy-dev-config.patch
- Edit session url in jmap-dart-client to /jmap/session
- isInsideCozy will be `false` if run on localhost, so in cozy_config_web.dart, return true on isInsideCozy
- in `env.file`, COZY_INTEGRATION=true and COZY_EXTERNAL_BRIDGE_VERSION=x.x.x (where x.x.x is the version of cozy-external-bridge)
- `flutter run -d chrome --web-port 2023 --web-browser-flag "--disable-web-security" --profile`

3. Access Cozy
- tmail cozy: http://tmail.localhost:8080/
- The password is `cozy`

### Run Cozy locally with modified Cozy libs
If there is a need of modifying Cozy libs
1. On cozy-libs side
- Clone `https://github.com/cozy/cozy-libs`
- `yarn install`
- `yarn build`
For example, if you want to use locally modified `cozy-external-bridge`
- `cd packages/cozy-external-bridge`
- `yarn link`
- `yarn build`

2. On cozy-twakemail side
- Look for rlink.sh file in /scripts, move the file to ~/Downloads
- `mv ~/Downloads/rlink.sh ~/bin/rlink`
- `chmod +x ~/bin/rlink`
- Reset the terminal
- Repeat part 1 of `Run Cozy locally`
- While cozy-stack is running, open another terminal in the same directory
- `rlink {library-you-modified-and-linked}` for example `rlink cozy-external-bridge`
- While rlink is running, run `yarn build`

3. On tmail side
- Repeat part 2 of `Run Cozy locally`

Note: You can leave the cozy-stack and rlink running if you plan to further modify Cozy libs. After each modification, run `yarn build` in cozy-libs packages side then run `yarn build` in cozy-twakemail side, then refresh the browser.