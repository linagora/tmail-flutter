# 54. Standardize HTML sanitizing

Date: 2024-10-24

## Status

Accepted

## Context

- The email content contains many unnecessary html attribute tags. We want to display the email content best on multiple platforms.

## Decision

- We sanitize the html before displaying the email.
  - Customize the `sanitize html` library to allow `attributes`, `tags` and `className` to be used.
  - The processing order is from `tags` -> `attributes` -> `className`

## Consequences

- Email content is cleaner. Displays well on all platforms. Any changes to sanitize html are updated here
