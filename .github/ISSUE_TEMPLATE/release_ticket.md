---
name: release template
about: Template for release checklist
title: 'Release new version '
labels: releasing
assignees: ''

---

### DoD:
- [ ] Request translating in weblate and merge to branch
- [ ] Test in all platforms base on the check-list case: [tnr-tmail-template_20Mar.ods](https://github.com/user-attachments/files/19358057/tnr-tmail-template_20Mar.ods)
  - Chrome
  - Firefox
  - Edge
  - Safari
  - Android
  - iOS
  - Opera
- [ ] Memory leak verifycation
  - View emails with heavy inline
  - Send multiple emails with heavy inline image and attachment
  - Create identity with heavy image
- [ ] Tag new version
- [ ] Push new docker image
- [ ] iOS - Release app in Test Flight
- [ ] Android - Release app in Internal Test
