---
name: release template
about: Template for release checklist
title: 'Release new version '
labels: releasing
assignees: ''

---

### DoD:
- [ ] Request translating in weblate and merge to branch
- [ ] Test in all platforms base on the check-list case:  [tnr-tmail-template.ods](https://github.com/user-attachments/files/16719554/tnr-tmail-template.ods)
  - Chrome
  - Firefox
  - Edge
  - Safari
  - Android
  - iOS
  - Opera
- [ ] Memory leak verifycation
- [ ] Tag new version
- [ ] Push new docker image
- [ ] iOS - Release app in Test Flight
- [ ] Android - Release app in Internal Test
