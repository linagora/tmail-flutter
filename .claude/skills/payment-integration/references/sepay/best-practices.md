# SePay Best Practices

Security, patterns, and monitoring for production SePay integrations.

## Security

### Credential Management
```javascript
// ✓ Good: Environment variables
const client = new SePayClient({
  merchant_id: process.env.SEPAY_MERCHANT_ID,
  secret_key: process.env.SEPAY_SECRET_KEY,
  env: process.env.NODE_ENV === 'production' ? 'production' : 'sandbox'
});

// ✗ Bad: Hardcoded credentials
const client = new SePayClient({
  merchant_id: 'SP-TEST-12345',
  secret_key: 'spsk_test_xxxxxxx'
});
```

### Webhook Security
1. **IP Whitelisting:** Restrict endpoint to SePay IPs
2. **API Key Verification:** Validate authorization header
3. **HTTPS Only:** Never accept HTTP webhooks
4. **Validate Payload:** Check all required fields exist
5. **Duplicate Detection:** Use transaction ID for deduplication

### Transaction Verification
```javascript
// Always verify payment status via API, don't trust only redirects
app.get('/payment/success', async (req, res) => {
  const orderId = req.query.order_id;

  // Verify via API call
  const order = await sePayClient.order.retrieve(orderId);

  if (order.status === 'completed') {
    await updateOrderStatus(orderId, 'paid');
    res.redirect(`/order/${orderId}/confirmation`);
  } else {
    res.redirect(`/order/${orderId}/pending`);
  }
});
```

## Implementation Patterns

### Payment Flow Pattern
```javascript
class PaymentService {
  async createPayment(order) {
    // 1. Create order in your system
    const paymentCode = `ORDER_${order.id}_${Date.now()}`;
    await this.savePaymentCode(order.id, paymentCode);

    // 2. Generate checkout form
    const fields = this.client.checkout.initOneTimePaymentFields({
      order_invoice_number: paymentCode,
      order_amount: order.total,
      currency: 'VND',
      success_url: `${config.baseUrl}/payment/success?order=${order.id}`,
      error_url: `${config.baseUrl}/payment/error?order=${order.id}`,
      cancel_url: `${config.baseUrl}/payment/cancel?order=${order.id}`,
      order_description: `Payment for Order #${order.id}`,
    });

    return fields;
  }

  async verifyPayment(orderId) {
    const paymentCode = await this.getPaymentCode(orderId);
    const payment = await this.client.order.retrieve(paymentCode);

    return {
      isPaid: payment.status === 'completed',
      amount: payment.amount,
      paidAt: payment.completed_at,
    };
  }
}
```

### Webhook Resilience Pattern
```javascript
async function handleWebhook(data) {
  const maxRetries = 3;
  let attempt = 0;

  while (attempt < maxRetries) {
    try {
      await db.transaction(async (trx) => {
        // Check duplicate
        const exists = await trx('transactions')
          .where('sepay_id', data.id)
          .first();

        if (exists) return;

        // Save transaction
        await trx('transactions').insert({
          sepay_id: data.id,
          amount: data.transferAmount,
          content: data.content,
          reference_code: data.referenceCode,
        });

        // Process payment
        const order = await findOrderByPaymentCode(data.content);
        if (order) {
          await markOrderAsPaid(order.id, trx);
        }
      });

      return { success: true };
    } catch (error) {
      attempt++;
      if (attempt >= maxRetries) throw error;
      await sleep(1000 * attempt); // Exponential backoff
    }
  }
}
```

### Reconciliation Pattern
```javascript
async function reconcilePayments(fromDate, toDate) {
  // Get all pending orders
  const pendingOrders = await Order.findPending();

  // Fetch SePay transactions in batches
  let sinceId = 0;
  const batchSize = 1000;

  while (true) {
    const transactions = await sePayClient.transaction.list({
      transaction_date_min: fromDate,
      transaction_date_max: toDate,
      transfer_type: 'in',
      since_id: sinceId,
      limit: batchSize,
    });

    if (transactions.length === 0) break;

    // Match and update
    for (const transaction of transactions) {
      const order = pendingOrders.find(o =>
        transaction.content.includes(o.payment_code)
      );

      if (order) {
        await order.markAsPaid(transaction);
      }
    }

    sinceId = transactions[transactions.length - 1].id;
  }
}
```

## Performance Optimization

### Caching
```javascript
// Cache bank list
const getBankList = memoize(
  async () => {
    const response = await fetch('https://qr.sepay.vn/banks.json');
    return response.json();
  },
  { maxAge: 86400000 } // 24 hours
);

// Cache QR codes for fixed amounts
const qrCache = new Map();

function getCachedQRUrl(account, bank, amount) {
  const key = `${account}-${bank}-${amount}`;
  if (!qrCache.has(key)) {
    const url = generateQRUrl(account, bank, amount);
    qrCache.set(key, url);
  }
  return qrCache.get(key);
}
```

### Rate Limit Management
```javascript
const RateLimiter = require('bottleneck');

const limiter = new RateLimiter({
  maxConcurrent: 1,
  minTime: 500, // 2 requests per second
  reservoir: 100,
  reservoirRefreshAmount: 100,
  reservoirRefreshInterval: 60000, // per minute
});

// Wrap API calls
const apiCall = limiter.wrap(async (endpoint, params) => {
  return await sePayClient.api.call(endpoint, params);
});
```

### Async Processing
```javascript
// Queue webhook processing
app.post('/webhook/sepay', async (req, res) => {
  // Respond immediately
  res.json({ success: true });

  // Queue for background processing
  await webhookQueue.add('process-sepay-webhook', req.body, {
    attempts: 3,
    backoff: {
      type: 'exponential',
      delay: 2000,
    },
  });
});

// Process in background worker
webhookQueue.process('process-sepay-webhook', async (job) => {
  await handleWebhook(job.data);
});
```

## Monitoring & Logging

### Essential Metrics
```javascript
const metrics = {
  payment_initiated: counter('sepay_payment_initiated_total'),
  payment_success: counter('sepay_payment_success_total'),
  payment_failed: counter('sepay_payment_failed_total'),
  webhook_received: counter('sepay_webhook_received_total'),
  webhook_processed: counter('sepay_webhook_processed_total'),
  api_errors: counter('sepay_api_errors_total'),
  processing_time: histogram('sepay_processing_duration_seconds'),
};

// Track metrics
metrics.payment_initiated.inc();
const timer = metrics.processing_time.startTimer();
// ... process payment
timer();
```

### Structured Logging
```javascript
logger.info('Payment initiated', {
  order_id: order.id,
  amount: order.total,
  payment_method: 'sepay',
  customer_id: customer.id,
});

logger.info('Webhook received', {
  transaction_id: webhook.id,
  amount: webhook.transferAmount,
  type: webhook.transferType,
  reference: webhook.referenceCode,
});

logger.error('Payment failed', {
  order_id: order.id,
  error: error.message,
  stack: error.stack,
  sepay_response: response,
});
```

### Alerting
```javascript
// Alert on high failure rate
if (failureRate > 0.1) { // 10%
  alert.send({
    severity: 'high',
    message: 'SePay payment failure rate exceeds 10%',
    details: { failureRate, total, failed },
  });
}

// Alert on webhook delivery failures
if (webhookFailures > 10) {
  alert.send({
    severity: 'medium',
    message: 'SePay webhook delivery failures',
    details: { failures: webhookFailures },
  });
}
```

## Testing Strategy

### Sandbox Testing Checklist
- [ ] Successful payment flow
- [ ] Failed payment handling
- [ ] Canceled payment handling
- [ ] Webhook delivery and processing
- [ ] Duplicate webhook handling
- [ ] Rate limit handling
- [ ] Error scenarios (network, timeout, invalid data)
- [ ] Payment verification via API
- [ ] QR code generation
- [ ] Order reconciliation

### Load Testing
```javascript
// Simulate high volume
for (let i = 0; i < 1000; i++) {
  await createPayment({
    amount: 100000,
    orderId: `LOAD_TEST_${i}`,
  });
  await sleep(100); // Respect rate limits
}
```

## Production Checklist

- [ ] Environment variables configured
- [ ] Production credentials obtained
- [ ] HTTPS enabled for all endpoints
- [ ] Webhook endpoint publicly accessible
- [ ] IP whitelisting configured
- [ ] Error monitoring set up
- [ ] Logging infrastructure ready
- [ ] Alerting configured
- [ ] Rate limiting implemented
- [ ] Database indexes created
- [ ] Reconciliation job scheduled
- [ ] Backup strategy in place
- [ ] Documentation updated
- [ ] Team trained on operations
