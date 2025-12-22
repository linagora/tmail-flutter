# Polar Best Practices

Security, patterns, and monitoring for production Polar integrations.

## Security

### Credential Management
```typescript
// ✓ Good: Environment variables
const polar = new Polar({
  accessToken: process.env.POLAR_ACCESS_TOKEN
});

// ✗ Bad: Hardcoded
const polar = new Polar({
  accessToken: 'polar_live_abc123'
});
```

### Webhook Security
```typescript
// Always verify signatures
app.post('/webhook/polar', async (req, res) => {
  try {
    const event = validateEvent(req.body, req.headers, secret);
    // Process verified event
  } catch (error) {
    return res.status(400).json({ error: 'Invalid signature' });
  }
});
```

### Never Expose Tokens Client-Side
```typescript
// ✓ Good: Server-side API route
export async function POST(req: Request) {
  const polar = new Polar({ accessToken: process.env.POLAR_ACCESS_TOKEN });
  const checkout = await polar.checkouts.create(...);
  return Response.json({ url: checkout.url });
}

// ✗ Bad: Client-side
const polar = new Polar({ accessToken: 'visible_in_browser' });
```

## Implementation Patterns

### Complete Payment Flow
```typescript
class PaymentService {
  async createCheckout(userId, priceId) {
    // 1. Create checkout session
    const session = await polar.checkouts.create({
      product_price_id: priceId,
      external_customer_id: userId,
      success_url: `${baseUrl}/success?checkout_id={CHECKOUT_ID}`,
      metadata: {
        user_id: userId,
        source: 'web'
      }
    });

    // 2. Log checkout creation
    await db.checkouts.insert({
      checkout_id: session.id,
      user_id: userId,
      status: 'pending'
    });

    return session.url;
  }

  async handleWebhook(event) {
    switch (event.type) {
      case 'order.paid':
        await this.fulfillOrder(event.data);
        break;

      case 'subscription.active':
        await this.grantAccess(event.data.customer.external_id);
        break;

      case 'subscription.revoked':
        await this.revokeAccess(event.data.customer.external_id);
        break;
    }
  }

  async fulfillOrder(order) {
    // Verify not already fulfilled
    const existing = await db.orders.findOne({ polar_id: order.id });
    if (existing) return;

    // Save order
    await db.orders.insert({
      polar_id: order.id,
      user_id: order.customer.external_id,
      amount: order.amount,
      status: 'paid'
    });

    // Grant access
    await this.grantAccess(order.customer.external_id);

    // Send confirmation
    await this.sendConfirmation(order);
  }
}
```

### Customer Portal Integration
```typescript
app.get('/portal', async (req, res) => {
  const session = await polar.customerSessions.create({
    external_customer_id: req.user.id
  });

  res.redirect(session.url);
});
```

### Usage-Based Tracking
```typescript
class UsageTracker {
  async trackUsage(userId, eventName, properties) {
    // Track in your system
    await db.usage.insert({
      user_id: userId,
      event_name: eventName,
      properties: properties,
      timestamp: new Date()
    });

    // Send to Polar for billing
    await polar.events.create({
      external_customer_id: userId,
      event_name: eventName,
      properties: properties
    });
  }

  async getBalance(userId, meterId) {
    const balance = await polar.meters.getBalance({
      external_customer_id: userId,
      meter_id: meterId
    });

    return balance.amount;
  }

  async showUsage(userId) {
    // Show customer their usage
    const usage = await db.usage.aggregate({
      user_id: userId,
      date: { $gte: startOfMonth() }
    });

    const balance = await this.getBalance(userId, meterId);

    return { usage, remaining: balance };
  }
}
```

## Data Management

### External ID Strategy
```typescript
// ✓ Good: Set external_id consistently
await polar.checkouts.create({
  external_customer_id: user.id, // Your user ID
  // ...
});

// Query by external_id
const customer = await polar.customers.get({
  external_id: user.id
});

// ✗ Bad: Storing Polar customer IDs
// Don't store polar_customer_id in your database
// Use external_id for all lookups
```

### Metadata Best Practices
```typescript
// Use metadata for:
{
  metadata: {
    user_id: '123',           // Internal ID
    source: 'web',            // Traffic source
    campaign: 'summer_sale',  // Marketing campaign
    referrer: 'partner_123'   // Referral tracking
  }
}

// Don't store sensitive data in metadata
// ✗ Bad: PII, passwords, payment details
```

### Database Sync
```typescript
async function syncSubscription(subscription) {
  await db.subscriptions.upsert({
    where: { polar_id: subscription.id },
    update: {
      status: subscription.status,
      current_period_end: subscription.current_period_end,
      cancel_at_period_end: subscription.cancel_at_period_end
    },
    create: {
      polar_id: subscription.id,
      user_id: subscription.customer.external_id,
      status: subscription.status,
      // ... other fields
    }
  });
}
```

## Performance Optimization

### Caching
```typescript
// Cache products list
const productCache = new Map();

async function getProducts(orgId) {
  if (!productCache.has(orgId)) {
    const products = await polar.products.list({
      organization_id: orgId,
      is_archived: false
    });
    productCache.set(orgId, products);
    setTimeout(() => productCache.delete(orgId), 300000); // 5 min
  }

  return productCache.get(orgId);
}
```

### Batch Operations
```typescript
// Batch event ingestion
const eventQueue = [];

async function trackEvent(userId, event) {
  eventQueue.push({ external_customer_id: userId, ...event });

  if (eventQueue.length >= 100) {
    await flushEvents();
  }
}

async function flushEvents() {
  const batch = eventQueue.splice(0, 100);
  await Promise.all(
    batch.map(event => polar.events.create(event))
  );
}
```

### Rate Limit Handling
```typescript
async function callWithRetry(fn, maxRetries = 3) {
  let attempt = 0;

  while (attempt < maxRetries) {
    try {
      return await fn();
    } catch (error) {
      if (error.statusCode === 429) {
        const retryAfter = error.headers?.['retry-after'] || 1;
        await sleep(retryAfter * 1000);
        attempt++;
      } else {
        throw error;
      }
    }
  }
}
```

## Monitoring & Logging

### Essential Metrics
```typescript
const metrics = {
  checkouts_created: counter('polar_checkouts_created_total'),
  orders_completed: counter('polar_orders_completed_total'),
  subscriptions_active: gauge('polar_subscriptions_active'),
  revenue: counter('polar_revenue_total'),
  webhook_processing_time: histogram('polar_webhook_duration_seconds')
};

// Track metrics
metrics.checkouts_created.inc({ product: productId });
metrics.orders_completed.inc({ amount: order.amount });
metrics.revenue.inc(order.amount);
```

### Structured Logging
```typescript
logger.info('Checkout created', {
  checkout_id: session.id,
  user_id: userId,
  product_id: priceId,
  amount: amount
});

logger.info('Order paid', {
  order_id: order.id,
  user_id: order.customer.external_id,
  amount: order.amount,
  billing_reason: order.billing_reason
});

logger.error('Webhook processing failed', {
  event_type: event.type,
  error: error.message,
  stack: error.stack
});
```

### Alerting
```typescript
// Alert on failed webhooks
if (webhookFailures > threshold) {
  alert.send({
    severity: 'high',
    message: 'Polar webhook failures exceed threshold',
    details: { failures: webhookFailures, threshold }
  });
}

// Alert on subscription churn
if (churnRate > 0.05) { // 5%
  alert.send({
    severity: 'medium',
    message: 'Subscription churn rate elevated',
    details: { churnRate, period: 'month' }
  });
}
```

## Testing Strategy

### Sandbox Testing
```typescript
// Use sandbox for development
const polar = new Polar({
  accessToken: process.env.POLAR_SANDBOX_TOKEN,
  server: "sandbox"
});

// Test scenarios:
// 1. Successful purchase
// 2. Failed payment
// 3. Subscription creation
// 4. Subscription upgrade/downgrade
// 5. Subscription cancellation
// 6. Refund processing
// 7. Webhook delivery
// 8. Benefit granting/revoking
```

### Test Cards
```typescript
const testCards = {
  success: '4242 4242 4242 4242',
  decline: '4000 0000 0000 0002',
  authRequired: '4000 0025 0000 3155'
};
```

### Integration Tests
```typescript
describe('Polar Integration', () => {
  it('creates checkout and processes payment', async () => {
    const session = await polar.checkouts.create({...});
    expect(session.url).toBeDefined();

    // Simulate successful payment (webhook)
    await simulateWebhook('order.paid', { ... });

    // Verify order fulfilled
    const order = await db.orders.findOne({ polar_id: orderId });
    expect(order.status).toBe('paid');
  });
});
```

## Production Checklist

- [ ] Environment variables configured
- [ ] Sandbox testing completed
- [ ] Production tokens obtained
- [ ] Webhook endpoint configured and tested
- [ ] Webhook signature verification implemented
- [ ] Error monitoring enabled
- [ ] Logging infrastructure ready
- [ ] Metrics collection configured
- [ ] Alerting rules set up
- [ ] Database indexes created
- [ ] Rate limiting handled
- [ ] Customer portal linked
- [ ] Email notifications configured
- [ ] Refund policy documented
- [ ] Support process established
- [ ] Team trained on platform
- [ ] Documentation updated
- [ ] Compliance requirements met (if applicable)
- [ ] Acceptable use policy reviewed

## Common Pitfalls

### 1. Not Verifying Webhooks
```typescript
// ✗ Bad: Trusting webhook data without verification
app.post('/webhook/polar', async (req, res) => {
  await handleEvent(req.body); // Vulnerable!
});

// ✓ Good: Always verify
app.post('/webhook/polar', async (req, res) => {
  const event = validateEvent(req.body, req.headers, secret);
  await handleEvent(event);
});
```

### 2. Trusting Only Success Redirects
```typescript
// ✗ Bad: Fulfilling based on redirect
app.get('/success', async (req, res) => {
  await fulfillOrder(req.query.checkout_id); // Insecure!
});

// ✓ Good: Verify via API or wait for webhook
app.get('/success', async (req, res) => {
  const checkout = await polar.checkouts.get(req.query.checkout_id);
  if (checkout.status === 'confirmed') {
    // Safe to show success page
  }
  // Still wait for webhook for fulfillment
});
```

### 3. Not Handling Duplicate Webhooks
```typescript
// ✓ Good: Idempotent webhook handling
async function handleOrderPaid(order) {
  const existing = await db.orders.findOne({ polar_id: order.id });
  if (existing) {
    console.log('Order already processed');
    return;
  }

  await fulfillOrder(order);
}
```

### 4. Hardcoding External IDs
```typescript
// ✗ Bad: Using Polar customer IDs
const customerId = 'cust_abc123';

// ✓ Good: Using your user IDs
const userId = user.id;
await polar.checkouts.create({
  external_customer_id: userId
});
```

### 5. Not Handling Failed Payments
```typescript
// Listen to subscription.past_due
if (event.type === 'subscription.past_due') {
  // Notify customer
  // Provide grace period
  // Update UI to show payment issue
}
```
