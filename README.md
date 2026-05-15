# FlashSale Pro

> Multi-tenant SaaS for high-concurrency flash sales — by **Dane Wu**

---

## The Problem

When a flash sale opens, thousands of buyers can hit "purchase" within
the same second. Two things must not break:

1. **Stock integrity** — the system cannot sell more units than exist
   (no oversells), even under concurrent claim attempts.
2. **Response time** — the order endpoint must stay snappy; emails and
   notifications cannot block the user response.

On top of that, the platform is multi-tenant — coaches run isolated
spaces, and one tenant must never see another tenant's data.

---

## My Solution

### 1. Atomic stock decrement under concurrency
**`app/controllers/flash_orders_controller.rb`**

```ruby
FlashOrder.transaction do
  @campaign.lock!  # SELECT ... FOR UPDATE (row-level Pessimistic Lock)

  if @campaign.remaining_stock > 0
    @order = @campaign.flash_orders.create!(...)
    @campaign.update!(remaining_stock: @campaign.remaining_stock - 1)
    OrderMailer.confirmation_email(@order).deliver_later
  end
end
```

### 2. Redis cache-aside for stock reads
**`app/models/flash_campaign.rb`**
- 1-minute TTL on `Rails.cache.fetch("campaign_#{id}_stock", ...)`.
- Cache invalidated by `after_save :update_stock_cache` on stock change.
- Public landing pages read from cache, not the DB.

### 3. Non-blocking email delivery
- `OrderMailer.confirmation_email(@order).deliver_later` — pushed to
  Active Job, runs in the background, never blocks the order endpoint.

### 4. Identity-based multi-tenant isolation
**`app/controllers/application_controller.rb`**
- Tenant derived from `current_user.tenant`, never from URL params.
- All queries flow through `current_tenant.<association>`
  (e.g. `current_tenant.orders.new(...)`), making IDOR attacks
  structurally impossible.

### 5. Idempotency on regular orders
**`app/controllers/orders_controller.rb`**
- Each new order pre-issues a UUID `idempotency_key`.
- `RecordNotUnique` rescue handles double-submits by redirecting to
  the existing order.

---

## Stack

- **Rails 8.2 (Edge)** — Solid Queue for background jobs
- **PostgreSQL** — pessimistic locking via `SELECT ... FOR UPDATE`
- **Redis** — cache-aside for stock reads
- **Hotwire** (Turbo/Stimulus) + **Tailwind CSS** — frontend
- **Active Storage** — campaign product images

---

## Roadmap

**Phase 1 — SaaS foundation ✅**
- Multi-tenant identity-based isolation
- Session-based authentication
- Token-based client invitation

**Phase 2 — High-concurrency core ✅**
- Pessimistic locking + transaction-wrapped stock decrement
- Redis cache layer for stock reads
- Async order confirmation emails

**Phase 3 — Financial + real-time (planned)**
- Stripe webhook integration with idempotency
- Real-time stock counter via Turbo Streams

---

## Quick Start

```bash
brew services start redis
bin/rails db:prepare
bin/rails dev:cache
bin/dev
```
