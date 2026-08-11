# Payment & Subscription — Handoff Audit

Audit of the current Flutter code against the **user-based subscription** handoff doc.
Legend: ✅ done · ⚠️ partial (needs a fix) · ❌ not done · ℹ️ info / no action.

> TL;DR: everything on the checklist is now **done**. The final gaps — the credit balance in the
> two banners, the "cancel at period end" UX, and the scheduled-downgrade date — were fixed in this
> pass (see the "Fixed in this pass" note under each). Only the optional ℹ️ cleanups remain.

---

## MUST DO

### ✅ 1. Display all money as `amount / 100` (it's cents)
Done everywhere money is shown:
- `widgets/plan_card.dart:596` (`_PriceRow`) and `:56` (`_formattedPrice`) — `amount / 100`.
- `data/models/my_subscription_model.dart:52` (`formattedAmount`) — `amount / 100`.

No `$7500`-style bug remains.

### ✅ 2. Read `credits.remaining`, not top-level `heroSpotlightCredits`
**Fixed in this pass.** All three sites now read the pooled balance:
- `pages/my_subscription_screen.dart` (`_CreditsCard`) — already used `credits.remaining` / `credits.total`.
- `widgets/active_plan_banner.dart` — now `sub.credits?.remaining ?? sub.heroSpotlightCredits`.
- `widgets/subscription_status_banner.dart` — now `sub.credits?.remaining ?? sub.heroSpotlightCredits`.

`heroSpotlightCredits` is kept only as a fallback for when `credits` is null.

### ✅ 3. Delete `discountPercent` / `netAmount`
Done — neither field exists anywhere in the subscription feature (models, controllers, widgets).
(The `discount` grep hits elsewhere are the unrelated raffles feature.)

### ✅ 4. Branch checkout on `switched` / `scheduled` / `free` / `paymentIntentClientSecret`
Done. `data/models/checkout_response_model.dart` parses all four; `canPresentSheet` gates the
PaymentSheet. `controllers/subscription_checkout_controller.dart:63-147` branches:
`isFree` → refetch, `scheduled` → refetch, `switched && !canPresentSheet` → success + refetch,
else `canPresentSheet` → Stripe PaymentSheet → poll `/my`.

### ✅ 5. Handle `data: null` from `/my` as "no subscription"
Done. `domain/services/subscription_service.dart:29-35` returns `null` when `data` isn't a map;
`plans_section` / `active_plan_banner` / `my_subscription_screen` all render the plan-picker /
empty state on null.

### ✅ 6. Keep sending `businessId` on `/subscriptions/checkout`
Done. `data/repositories/subscription_repository.dart:51` always posts `{planId, businessId}`;
both checkout controllers resolve a business id first.

---

## SHOULD DO

### ✅ 7. Remove the "active until <date>" cancel branch (cancellation is immediate)
**Fixed in this pass — all 5 sites updated:**
- `controllers/subscription_controller.dart` — always clears the plan + "Subscription cancelled"
  toast; removed the "stays active until …" branch and the now-unused `_formatDate`.
- `controllers/my_subscription_controller.dart` — always sets `_subscription = null` after cancel.
- `widgets/active_plan_banner.dart` — `_periodText` only says "Renews on …"; dialog copy now
  states cancellation is immediate and non-refundable.
- `widgets/subscription_status_banner.dart` — "Renews on …" only; Cancel button no longer gated on
  `cancelAtPeriodEnd`.
- `pages/my_subscription_screen.dart` — `renewLabel` is always "Renews on"; dialog copy updated.

The `cancelAtPeriodEnd` field is still parsed on `MySubscriptionModel` (harmless), but nothing reads
it for UI anymore.

### ✅ 8. Show `pendingPlanName` + `effectiveDate` when a downgrade is scheduled
**Fixed in this pass.** The scheduled (downgrade) target card in `widgets/plan_card.dart` now shows
`_pendingLabel(...)` → "Starts <MMM d>" using the current plan's `currentPeriodEnd` (the effective
date), falling back to "Starts at next renewal" when the date is unknown. The `_ScheduledBadge` +
`pendingPlanId` matching already identified *which* plan; this adds the *when*.

### ✅ 9. Present the plan as account-level, not per-business
Effectively done — there is a single account-level plan picker and one "My Subscription" screen;
no per-business plan UI. (It still *resolves* a business id to satisfy checkout, which is fine.)

---

## NO LONGER NEEDED — confirmed absent

- ✅ Per-business subscription screens — none exist; one picker covers the account.
- ✅ Multi-business discount display — not present anywhere.

---

## ℹ️ Extra observations (not on the checklist)

- **Stale repo comments / unnecessary business gate.** `data/repositories/subscription_repository.dart:32-34,59-60`
  still say `businessId` is *required* and the backend *400s* without it on `/my` and `DELETE`.
  The new doc says it's *accepted but ignored* there. Sending it is harmless, but the app also
  *blocks* `/my` when the user has no business (`my_subscription_controller.dart:40-43`,
  `subscription_checkout_controller.dart:167-168`). Under the per-user model a subscriber without a
  currently-resolvable business could be blocked from *viewing* their plan. Low priority, but worth
  loosening the `/my` and `DELETE` paths to not hard-require a business id.
- **Two overlapping controllers.** `SubscriptionController` (`controllers/subscription_controller.dart`)
  is still registered (`subscription_binding.dart:15`) but the live plans UI uses
  `SubscriptionCheckoutController`. `SubscriptionController` is only reached for Stripe init on login
  (`login_controller.dart:24`); its `subscribeToPlan` / `cancelSubscription` (with the stale
  "stays active until…" copy) appear unused by UI. Consider deleting the dead methods or the whole
  controller once init is moved, to avoid the stale-copy trap in item 7.
- **Free-plan event mismatch (backend).** Doc notes Free can't create events despite its feature
  list saying "1 active event". Plan features render straight from the API, so no client change is
  needed — just don't hard-code a promise of a Free event.

---

## Action list

1. ✅ **[must, done]** Banners now use `credits?.remaining` (items 2).
2. ✅ **[should, done]** Cancel is immediate everywhere; dialog/toast copy updated (item 7).
3. ✅ **[should, done]** Scheduled downgrade card shows the effective date (item 8).
4. ⬜ **[optional]** Loosen the "needs a business" gate on `/my` + `DELETE`; clean up stale repo comments and the duplicate `SubscriptionController` (item ℹ️). *Left as-is — behavioural change, low priority.*

All checklist items (must + should) are complete and `flutter analyze lib/features/subscription`
reports **no issues**.
