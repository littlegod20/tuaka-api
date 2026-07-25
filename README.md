# TuaKa API Project

> REST API powering the [TuaKa](https://tuaka.org) invoicing platform — multi-tenant, queue-driven, and built for West African small businesses.

---

## Table of contents

- [Overview](#overview)
- [Tech stack](#tech-stack)
- [Project structure](#project-structure)
- [Getting started](#getting-started)
- [Environment variables](#environment-variables)
- [Database](#database)
- [Authentication](#authentication)
- [API reference](#api-reference)
- [Queue and jobs](#queue-and-jobs)
- [Multi-tenancy](#multi-tenancy)
- [Git workflow](#git-workflow)
- [Related repositories](#related-repositories)

---

## Overview

TuaKa API is a Laravel 11 REST API that serves two frontend applications — the business portal used by tenants, and the admin portal used by the platform owner.

The API is responsible for:

- Multi-tenant isolation via subdomain resolution and Eloquent global scopes
- JWT authentication with separate guards for tenants and platform admin
- Invoice and quote lifecycle management
- PDF generation and email delivery via Mailgun
- Payment processing via Paystack (subscriptions) and MTN MoMo (invoice payments)
- Asynchronous job processing via Laravel Horizon
- Subscription billing with grace period handling

---

## Tech stack

| Layer | Technology |
|-------|-----------|
| Framework | Laravel 11 |
| Language | PHP 8.2+ |
| Database | PostgreSQL 15 |
| Cache / Sessions | Redis |
| Queue | Laravel Horizon (Redis) |
| Authentication | JWT (`php-open-source-saver/jwt-auth`) |
| PDF generation | DomPDF (`barryvdh/laravel-dompdf`) |
| Email | Mailgun via Laravel Mail |
| Payments | Paystack · MTN MoMo |
| Server | Ubuntu 22.04 + Nginx + PHP-FPM |

---

## Project structure

```
tuaka-api/
├── app/
│   ├── Http/
│   │   ├── Controllers/
│   │   │   └── Api/V1/
│   │   │       ├── Auth/           # Login, register, refresh, logout
│   │   │       ├── Tenant/         # Tenant settings, team management
│   │   │       ├── Invoice/        # Invoice and quote CRUD + lifecycle
│   │   │       ├── Client/         # Client contact management
│   │   │       ├── Product/        # Saved products and services
│   │   │       ├── Billing/        # Subscription plans, payments
│   │   │       └── Webhook/        # Paystack and MoMo webhook handlers
│   │   ├── Middleware/
│   │   │   ├── ResolveTenant.php   # Identifies tenant from subdomain
│   │   │   └── EnsureActiveSubscription.php
│   │   └── Resources/              # API response transformers
│   ├── Models/
│   │   ├── Tenant.php
│   │   ├── User.php
│   │   ├── Plan.php
│   │   ├── Subscription.php
│   │   ├── Invoice.php
│   │   ├── InvoiceItem.php
│   │   ├── InvoiceActivity.php
│   │   ├── Client.php
│   │   ├── Product.php
│   │   ├── Payment.php
│   │   └── Admin.php
│   ├── Services/
│   │   ├── PaymentService.php      # Abstracts Paystack and MoMo
│   │   ├── SubscriptionService.php
│   │   ├── InvoiceService.php
│   │   └── TenantService.php
│   └── Jobs/
│       ├── SendInvoiceEmail.php
│       ├── SendInvoiceReminder.php
│       ├── GenerateInvoicePdf.php
│       └── ProcessWebhook.php
├── database/
│   ├── migrations/
│   └── seeders/
│       ├── PlanSeeder.php
│       └── AdminSeeder.php
├── routes/
│   ├── api.php                     # Protected tenant routes
│   └── web.php                     # Public invoice view routes
└── config/
    ├── auth.php
    └── cors.php
```

---

## Getting started

### Prerequisites

```bash
php --version       # 8.2 or higher
composer --version  # 2.x
psql --version      # PostgreSQL 15+
redis-cli --version # Redis 7+
```

### Installation

```bash
git clone https://github.com/YOUR_USERNAME/tuaka-api.git
cd tuaka-api

composer install

cp .env.example .env
php artisan key:generate
php artisan jwt:secret
```

Create the database:

```bash
psql -U postgres -c "CREATE DATABASE tuaka;"
```

Run migrations and seeders:

```bash
php artisan migrate
php artisan db:seed
```

Start the development server:

```bash
php artisan serve
# API running at http://localhost:8000
```

Start the queue worker (separate terminal):

```bash
php artisan horizon
# Horizon dashboard at http://localhost:8000/horizon
```

---

## Environment variables

Copy `.env.example` to `.env` and fill in the values below.

```env
# Application
APP_NAME=TuaKa
APP_ENV=local
APP_DEBUG=true
APP_URL=http://localhost:8000
FRONTEND_URL=http://localhost:3001

# Database
DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=tuaka
DB_USERNAME=postgres
DB_PASSWORD=

# JWT
JWT_SECRET=
JWT_TTL=1440

# Queue and cache
QUEUE_CONNECTION=redis
CACHE_STORE=redis
REDIS_HOST=127.0.0.1
REDIS_PORT=6379

# Mail
MAIL_MAILER=smtp
MAIL_HOST=smtp.mailgun.org
MAIL_PORT=587
MAIL_USERNAME=
MAIL_PASSWORD=
MAIL_FROM_ADDRESS=noreply@tuaka.app
MAIL_FROM_NAME=TuaKa

# Paystack
PAYSTACK_SECRET_KEY=
PAYSTACK_PUBLIC_KEY=
PAYSTACK_WEBHOOK_SECRET=

# MTN MoMo
MOMO_BASE_URL=https://sandbox.momodeveloper.mtn.com
MOMO_SUBSCRIPTION_KEY=
MOMO_API_USER=
MOMO_API_KEY=
MOMO_TARGET_ENVIRONMENT=sandbox

# Local development
# Tenant slug to use when running on localhost (no subdomain available)
DEV_TENANT=acme
```

> **Never commit `.env` to git.** It is listed in `.gitignore` by default.

---

## Database

### Schema overview

| Table | Description |
|-------|-------------|
| `tenants` | Registered businesses on the platform |
| `users` | Team members belonging to a tenant |
| `admins` | Platform super-admins (separate from users) |
| `plans` | Subscription plan definitions |
| `subscriptions` | Live subscription state per tenant |
| `clients` | Contacts a tenant invoices |
| `products` | Saved services / line item templates |
| `invoices` | Invoices and quotes |
| `invoice_items` | Line items belonging to an invoice |
| `invoice_activities` | Audit log of all invoice events |
| `payments` | Payment records from Paystack and MoMo |

### Useful commands

```bash
# Run all pending migrations
php artisan migrate

# Fresh wipe and re-migrate (development only)
php artisan migrate:fresh --seed

# Roll back the last batch
php artisan migrate:rollback

# Seed plans only
php artisan db:seed --class=PlanSeeder
```

### Seeded plans

| Plan | Monthly (GHS) | Invoice limit |
|------|--------------|---------------|
| Free | 0 | 5 |
| Basic | 90 | 50 |
| Pro | 250 | Unlimited |

> All monetary values are stored in the smallest currency unit (pesewas for GHS). GHS 90.00 is stored as `9000`.

---

## Authentication

The API uses two separate JWT guards:

### Tenant guard (`api`)

Used by business portal users. The token contains `tenant_id` and `role`.

```
POST /api/v1/register    # create tenant + owner account
POST /api/v1/login       # returns JWT token
POST /api/v1/refresh     # refresh an expiring token
POST /api/v1/logout      # invalidate token
```

Include the token in every protected request:

```
Authorization: Bearer {token}
X-Tenant: {slug}
```

### Admin guard (`admin`)

Used exclusively by the platform owner. Separate login endpoint, separate token.

```
POST /api/v1/admin/login
```

### Tenant resolution

Every request to a protected route passes through `ResolveTenant` middleware, which reads the `X-Tenant` header (set by Nginx from the subdomain) and scopes the entire request to that tenant.

Locally, since there is no subdomain, the middleware falls back to the `DEV_TENANT` value in `.env`.

---

## API reference

All endpoints are prefixed with `/api/v1`. Protected routes require `Authorization: Bearer {token}` and `X-Tenant: {slug}` headers.

### Auth

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/register` | Register new tenant and owner |
| POST | `/login` | Login, returns JWT |
| POST | `/refresh` | Refresh JWT token |
| POST | `/logout` | Invalidate JWT token |

### Invoices

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/invoices` | List invoices (filterable by status, type) |
| POST | `/invoices` | Create invoice or quote |
| GET | `/invoices/{id}` | Get single invoice with items and activity |
| PUT | `/invoices/{id}` | Update draft invoice |
| DELETE | `/invoices/{id}` | Delete draft invoice |
| POST | `/invoices/{id}/send` | Send invoice to client |
| POST | `/invoices/{id}/mark-paid` | Mark invoice as paid manually |
| POST | `/invoices/{id}/convert` | Convert quote to invoice |

### Clients

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/clients` | List all clients |
| POST | `/clients` | Create client |
| GET | `/clients/{id}` | Get client with invoice history |
| PUT | `/clients/{id}` | Update client |
| DELETE | `/clients/{id}` | Delete client |

### Products

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/products` | List saved products |
| POST | `/products` | Create product |
| PUT | `/products/{id}` | Update product |
| DELETE | `/products/{id}` | Delete product |

### Billing

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/plans` | List all active plans |
| POST | `/billing/subscribe` | Subscribe to a plan |
| POST | `/billing/cancel` | Cancel subscription |
| GET | `/billing/invoices` | List subscription invoices |

### Team

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/team` | List team members |
| POST | `/team/invite` | Invite a team member |
| DELETE | `/team/{id}` | Remove team member |

### Public routes (no auth required)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/inv/{token}` | View public invoice page |
| POST | `/inv/{token}/pay` | Initiate MoMo payment |

### Webhooks (no auth, signature-verified)

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/webhooks/paystack` | Paystack payment events |
| POST | `/webhooks/momo` | MTN MoMo payment events |

---

## Queue and jobs

Jobs are processed by Laravel Horizon. The following jobs run asynchronously:

| Job | Trigger | Retries |
|-----|---------|---------|
| `SendInvoiceEmail` | Invoice sent | 3 |
| `SendInvoiceReminder` | Scheduled on send | 3 |
| `GenerateInvoicePdf` | Invoice sent or downloaded | 3 |
| `ProcessWebhook` | Payment webhook received | 5 |

### Running Horizon locally

```bash
php artisan horizon
```

Horizon dashboard (protected, local only):

```
http://localhost:8000/horizon
```

### Laravel Scheduler

The scheduler runs subscription renewal checks daily. On the production server this requires one cron entry:

```bash
* * * * * cd /var/www/tuaka-api && php artisan schedule:run >> /dev/null 2>&1
```

Scheduled tasks:

| Task | Schedule | Description |
|------|----------|-------------|
| `RenewSubscriptions` | Daily midnight | Charges tenants whose billing period ends today |
| `ExpireGracePeriods` | Daily midnight | Downgrades tenants past their grace period |
| `CleanExpiredInvites` | Daily | Removes unaccepted invitations older than 7 days |

---

## Multi-tenancy

The API uses a **shared database with tenant scoping** strategy.

Every resource table has a `tenant_id` column. All Eloquent models that belong to a tenant use a `TenantScope` global scope that automatically appends `WHERE tenant_id = ?` to every query.

The active tenant is resolved in `ResolveTenant` middleware from the `X-Tenant` request header, which Nginx sets from the subdomain on every incoming request:

```
acme.tuaka.app → X-Tenant: acme → tenants WHERE slug = 'acme' → set active tenant
```

This means tenant isolation is automatic and invisible in controllers:

```php
// Returns only invoices belonging to the active tenant
// No manual WHERE clause needed anywhere
Invoice::all();
```

---

## Git workflow

### Branch naming

```
main        → production-ready code only
develop     → integration branch
feature/xxx → new features
fix/xxx     → bug fixes
```

### Commit message format

```
type: short description

Types: init | feat | fix | refactor | docs | chore | test
```

### Examples

```bash
git commit -m "feat: add invoice send endpoint with queue dispatch"
git commit -m "fix: correct tenant scope on payment queries"
git commit -m "chore: add PlanSeeder with three default plans"
```

---

## Related repositories

| Repository | Description |
| ---------- | ----------- |
| [`tuaka-web`](https://github.com/littlegod20/tuaka-web) | React monorepo — admin portal and business portal |

---

*TuaKa API — Pay up. Move forward.*# Tuaka API
