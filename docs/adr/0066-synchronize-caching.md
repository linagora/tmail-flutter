# 66. Synchronize caching

Date: 2025-06-18

## Status

Accepted

## Context

Synchronizing server and database data is quite troublesome, 
when we use many protocols to receive mails (FCM, WebSocket, Memory operator). 
In addition, we are using `Hive` database to store data, 
it does not support multiple isolate to access the database. 
This leads to inconsistent database data, sometimes corrupted and lost data.

## Decision

To overcome this problem we need a database that can support multiple isolate.
So we need to use [Hive_CE](https://pub.dev/packages/hive_ce) to replace `Hive` database.
Hive CE is a spiritual continuation of Hive v2 with the following new features, such as:

  - Isolate support through IsolatedHive
  - Automatic type adapter generation using the GenerateAdapters annotation
  - No more manually adding annotations to every type and field
  - Generate adapters for classes outside the current package
  - A HiveRegistrar extension that lets you register all your generated adapters in one call
  - Extends the maximum type ID from 223 to 65439
  ...

## Consequences

- Data is always synchronized with the latest
