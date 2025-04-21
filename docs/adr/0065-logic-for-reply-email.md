# 65. Logic for reply email

Date: 2025-04-21

## Status

Accepted

## Context

- The email reply logic is quite complex so to avoid mistakes and regression of errors later.

## Decision

Brief the logic flow to easily follow changes during email reply process:

**1. Reply:**

- If the user is the `sender`

```console
To = email.to
Cc, Bcc, ReplyTo = Empty
```

- Otherwise, If the email has a `List-Post` header then:

```console
To = email.from.withoutUser
Cc, Bcc, ReplyTo = Empty
```

- Otherwise, If the email without a `List-Post` header, `email.replyTo` is not empty then:

 ```console
To = email.replyTo.withoutUser
Cc, Bcc, ReplyTo = Empty
```

- Otherwise:

```console
To = email.from.withoutUser
Cc, Bcc, ReplyTo = Empty
```

**2. Reply To List:**

- If the email has a `List-Post` header then:

```console
To = email.List-Post.withoutUser
Cc, Bcc, ReplyTo = Empty
```

- Otherwise: There is no `Reply To List` feature

3. Reply all

- If the user is the sender

```console
To = email.to.withoutUser
Cc = email.cc.withoutUser
Bcc = email.bcc.withoutUser
ReplyTo = email.replyTo.withoutUser
```

- Otherwise, If the email has a `List-Post` header then:

```console
To = (email.replyTo + email.from + email.to).withoutUser
Cc = email.cc.withoutUser
Bcc = email.bcc.withoutUser
ReplyTo = Empty
```

- Otherwise, If the email without a `List-Post` header, `email.replyTo` is not empty then:

```console
To = (email.replyTo + email.to).withoutUser
Cc = email.cc.withoutUser
Bcc = email.bcc.withoutUser
ReplyTo = Empty
```

- Otherwise

```console
To = (email.from + email.to).withoutUser
Cc = email.cc.withoutUser
Bcc = email.bcc.withoutUser
ReplyTo = Empty
```

## Consequences

- Any changes to reply email should be updated in this ADR.
