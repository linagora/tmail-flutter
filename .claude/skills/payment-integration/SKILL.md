---
name: payment-integration
description: Implement payment integrations with SePay (Vietnamese payment gateway with VietQR, bank transfers, cards) and Polar (global SaaS monetization platform with subscriptions, usage-based billing, automated benefits). Use when integrating payment processing, implementing checkout flows, managing subscriptions, handling webhooks, processing bank transfers, generating QR codes, automating benefit delivery, or building billing systems. Supports authentication (API keys, OAuth2), product management, customer portals, tax compliance (Polar as MoR), and comprehensive SDK integrations (Node.js, PHP, Python, Go, Laravel, Next.js).
version: 1.0.0
license: MIT
---

# Payment Integration

Implement payment processing with SePay (Vietnamese payments) and Polar (global SaaS monetization).

## When to Use

Use when implementing:
- Payment gateway integration (checkout, processing)
- Subscription management (trials, upgrades, billing)
- Webhook handling (payment notifications)
- QR code payments (VietQR, NAPAS)
- Usage-based billing (metering, credits)
- Automated benefit delivery (licenses, GitHub access, Discord roles)
- Customer portals (self-service management)
- Bank transfer automation (Vietnamese banks)
- Product catalogs with pricing

## Platform Selection

**Choose SePay for:**
- Vietnamese market (VND currency)
- Bank transfer automation
- VietQR/NAPAS payments
- Local payment methods
- Direct bank account monitoring

**Choose Polar for:**
- Global SaaS products
- Subscription management
- Usage-based billing
- Automated benefits (GitHub, Discord, licenses)
- Merchant of Record (tax compliance)
- Digital product sales

## Quick Reference

### SePay Integration
- **Overview & Auth**: `references/sepay/overview.md` - Platform capabilities, API/OAuth2 auth, supported banks
- **API Reference**: `references/sepay/api.md` - Endpoints, transactions, bank accounts, virtual accounts
- **Webhooks**: `references/sepay/webhooks.md` - Setup, payload structure, verification, retry logic
- **SDK Usage**: `references/sepay/sdk.md` - Node.js, PHP, Laravel implementations
- **QR Codes**: `references/sepay/qr-codes.md` - VietQR generation, templates, integration
- **Best Practices**: `references/sepay/best-practices.md` - Security, patterns, monitoring

### Polar Integration
- **Overview & Auth**: `references/polar/overview.md` - Platform capabilities, authentication methods, MoR concept
- **Products & Pricing**: `references/polar/products.md` - Product types, pricing models, usage-based billing
- **Checkouts**: `references/polar/checkouts.md` - Checkout flows, embedded checkout, links
- **Subscriptions**: `references/polar/subscriptions.md` - Lifecycle, upgrades, downgrades, trials
- **Webhooks**: `references/polar/webhooks.md` - Event types, signature verification, monitoring
- **Benefits**: `references/polar/benefits.md` - Automated delivery (GitHub, Discord, licenses, files)
- **SDK Usage**: `references/polar/sdk.md` - TypeScript, Python, PHP, Go, framework adapters
- **Best Practices**: `references/polar/best-practices.md` - Security, patterns, monitoring

### Integration Scripts
- **SePay Webhook Verification**: `scripts/sepay-webhook-verify.js` - Verify SePay webhook authenticity
- **Polar Webhook Verification**: `scripts/polar-webhook-verify.js` - Verify Polar webhook signatures
- **Checkout Helper**: `scripts/checkout-helper.js` - Generate checkout sessions for both platforms

## Implementation Workflow

### SePay Implementation
1. Load `references/sepay/overview.md` for auth setup
2. Load `references/sepay/api.md` or `references/sepay/sdk.md` for integration
3. Load `references/sepay/webhooks.md` for payment notifications
4. Use `scripts/sepay-webhook-verify.js` for webhook verification
5. Load `references/sepay/best-practices.md` for production readiness

### Polar Implementation
1. Load `references/polar/overview.md` for auth and concepts
2. Load `references/polar/products.md` for product setup
3. Load `references/polar/checkouts.md` for payment flows
4. Load `references/polar/webhooks.md` for event handling
5. Use `scripts/polar-webhook-verify.js` for webhook verification
6. Load `references/polar/benefits.md` if automating delivery
7. Load `references/polar/best-practices.md` for production readiness

## Key Capabilities

**SePay:**
- Payment gateway (QR, bank transfer, cards)
- Bank account monitoring with webhooks
- Order-based virtual accounts
- VietQR generation API
- 44+ Vietnamese banks supported
- Rate limit: 2 calls/second

**Polar:**
- Merchant of Record (global tax compliance)
- Subscription lifecycle management
- Usage-based billing (events, meters)
- Automated benefits (GitHub, Discord, licenses)
- Customer portal (self-service)
- Multi-language SDKs
- Rate limit: 300 req/min

## Instructions

When implementing payment integration:

1. **Identify platform** based on requirements (Vietnamese vs global, payment types)
2. **Load relevant references** progressively as needed
3. **Implement authentication** using platform-specific methods
4. **Set up products/pricing** according to business model
5. **Implement checkout flow** (hosted, embedded, or API-driven)
6. **Configure webhooks** with proper verification
7. **Handle payment events** (success, failure, refund)
8. **Test thoroughly** in sandbox before production
9. **Monitor and optimize** using platform analytics

Load only the references needed for current implementation step to maintain context efficiency.
