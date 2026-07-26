# Subscription — User Manual & Developer Guide

Everything about the Loci subscription flow: what the plans are, which APIs
drive them, how every purchase path behaves in the UI, and how the app reacts
when a feature isn't covered by the current plan.

---

## 1. Who can subscribe

Subscriptions are for **business owners**. A user must have at least one
business (claimed or created) before checkout — `subscribe()` resolves the
caller's first business via `GET /businesses/me` and sends its id with the
checkout. Without a business the app shows:
*"You need a business before subscribing. Please claim or create one first."*

## 2. Plan catalog

Served by `GET /subscriptions/plans?billingType=monthly|one_time`.
Amounts are displayed **exactly as the backend sends them** (no cents
conversion — `5000` renders as `$5000`).

### Monthly (recurring)

| Plan | id | Amount | Credits | Features |
|------|----|--------|---------|----------|
| Free | `free` | 0 | 0 | Business listing, 1 active event |
| Be Seen | `be_seen_monthly` | 5000 | 75 | Route creation, Community management, Lead export |
| Build Locally | `build_locally_monthly` | 7500 | 200 | Unlimited events, Raffle creation, Featured placement |

### One-time (credit packs)

| Plan | id | Amount | Credits |
|------|----|--------|---------|
| Starter Boost | `starter_boost` | 15000 | 150 |
| Local Push | `local_push` | 30000 | 350 |
| Event Spotlight | `event_spotlight` | 50000 | 700 |
| Hero Partner | `hero_partner` | 100000 | 1500 |

> The catalog is backend-driven — new plans appear automatically; this table
> reflects the catalog at the time of writing.

## 3. API endpoints

| Purpose | Method & path | Notes |
|---------|---------------|-------|
| Stripe publishable key | `GET /subscriptions/config` | used by `StripeService.init()` |
| Plan catalog | `GET /subscriptions/plans?billingType=` | `monthly` or `one_time` |
| Checkout | `POST /subscriptions/checkout` | body `{ planId, businessId }` |
| Current subscription | `GET /subscriptions/my` | `data: null` ⇒ no subscription |
| Cancel | `DELETE /subscriptions/my` | same endpoint, DELETE method |

### Checkout response shapes (`POST /subscriptions/checkout`)

| Shape | Markers | App behaviour |
|-------|---------|---------------|
| A. Free plan | `free: true` | Activates instantly, no PaymentSheet |
| B. New monthly | PaymentSheet params + `subscriptionId` | Stripe PaymentSheet opens |
| C. One-time pack | PaymentSheet params, no `subscriptionId` | Stripe PaymentSheet opens |
| D. Upgrade | `switched: true` | Applied immediately in place; sheet only if a prorated charge needs confirming |
| E. Downgrade | `scheduled: true`, `pendingPlanName`, `effectiveDate` | Nothing charged now; switch happens at period end |

### `GET /subscriptions/my` fields the UI uses

`status` (`active` / `past_due` / `incomplete` / …), `planId`, `planName`,
`amount`, `billingType`, `currentPeriodStart/End`, `cancelAtPeriodEnd`,
`heroSpotlightCredits`, `credits { total, used, remaining }`, and
`pendingPlanId` / `pendingPlanName` while a downgrade is scheduled.

## 4. Purchase flows (what the user sees)

All flows start from the **Subscription Plan** page (drawer) — a pinned
Monthly / One-time toggle over the plan cards. Tapping **Subscribe** shows a
loader on that card's button and disables all other subscribe buttons.

- **Free plan** — activates instantly; the card flips to **Current Plan**.
- **Paid plan (new)** — Stripe PaymentSheet opens; after payment the app polls
  `GET /my` (up to 8×1s) until active. Dismissing the sheet is silent.
- **Upgrade** — applied immediately; the card flips to the new plan.
- **Downgrade** — scheduled for period end: the target card shows a
  **Scheduled** badge and a *"Starts at next renewal"* bar; the current plan
  keeps running until `effectiveDate`.

**Feedback policy:** success is shown by the UI state itself (card badges,
banner) — **no success snackbars**. Only genuine errors toast: payment
failure, missing business, payments unavailable, generic failure.

## 5. Where the subscription is visible

1. **Plan list page** — `ActivePlanBanner` on top: status, credits pill,
   renew/end date, and **Cancel subscription** (shown for any active plan,
   free included, even when already set to end).
2. **Settings → My Subscription** — plan card with status badge and raw
   amount, credits usage bar, billing period card, and the same cancel button
   with its own loader. Refreshed on every visit (intentionally not cached, so
   it's always current after a purchase/cancel).

Cancel = `DELETE /subscriptions/my`. On success there is no toast — the
banner/screen simply reflects the new state (`cancelAtPeriodEnd: true` shows
*"Ends on <date>"*).

## 6. Entitlements & the upgrade paywall

When a business owner tries something their plan doesn't cover (creating an
event/route/raffle beyond the plan, spending credits they don't have…), the
backend rejects the request with a message mentioning the plan/subscription.

Instead of surfacing that as a raw red snackbar, the app opens a global
**upgrade paywall bottom sheet**: premium icon, the backend's own message,
**View plans** (navigates to the subscription page) and **Maybe later**.

How it works (no per-feature code needed):

- Every controller already funnels errors through `SnackbarService.error`.
- `SnackbarService.errorInterceptor` (wired in `AppBindings`) runs first; it
  points at `UpgradeRequiredSheet.maybeIntercept`.
- `maybeIntercept` matches the message against an entitlement pattern
  (`subscription`, `upgrade`, `plan`, `limit reached`, `active event`,
  `credits left/remaining/required`). On match it shows the sheet and
  swallows the snackbar; otherwise the normal snackbar appears.
- Guards: only one sheet at a time, and never shown while already on the
  subscription page.

**Tuning:** if the backend adds new entitlement wordings, extend
`UpgradeRequiredSheet._entitlementPattern` — deliberately conservative so a
generic 403 ("You don't have permission…") never opens the paywall.

## 7. Caching & lifecycle

- `PlansController` and `SubscriptionCheckoutController` are **permanent**
  (registered once in `DrawerBindings`), so plans and subscription state
  survive navigation — revisiting the page doesn't reload or flash shimmer.
- Plans are cached **per billing type**; switching Monthly ⇄ One-time after
  the first load is instant. Pull-to-refresh clears the cache.
- `MySubscriptionController` (settings page) is per-route on purpose — it
  refetches on entry so status is always fresh.

## 8. File map

| Layer | File |
|-------|------|
| URLs | `core/constants/app_url.dart` (`subscriptionPlans/Config/Checkout`, `mySubscription`) |
| Repository | `data/repositories/subscription_repository.dart` |
| Service | `domain/services/subscription_service.dart` |
| Models | `data/models/plan_response_model.dart`, `checkout_response_model.dart`, `my_subscription_model.dart`, `subscription_config_model.dart` |
| Controllers | `presentation/controllers/plans_controller.dart`, `subscription_checkout_controller.dart`, `my_subscription_controller.dart` |
| Pages | `presentation/pages/subscription_screen.dart`, `my_subscription_screen.dart` |
| Key widgets | `plan_card.dart`, `plan_list.dart`, `plans_section.dart`, `active_plan_banner.dart`, `billing_toggle*.dart`, `subscription_shimmer.dart`, `upgrade_required_sheet.dart` |
| Bindings | `DrawerBindings` (plan page, permanent), `my_subscription_binding.dart` (settings page) |
| Stripe | `core/services/stripe_service.dart` (init from `/config`, themed PaymentSheet appearance) |
| Paywall wiring | `core/utils/show_snackbar.dart` (`errorInterceptor`) + `core/di/bindings/app_bindings.dart` |
