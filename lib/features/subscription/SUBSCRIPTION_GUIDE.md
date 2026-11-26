# Loci subscription implementation guide

Status: implementation proposal, reviewed against the Flutter repository on 5 November 2026. The backend repository was not available for review. Endpoint contracts and guards below are requirements to implement, not claims that they already exist. The business rules supplied by the product owner govern this guide.

## Plans and access

| Plan | Store product ID | Intended price | Access | Spotlight allowance |
| --- | --- | --- | --- | --- |
| Free | None | $0 | Community, reviews, exploration, business claiming | 0 |
| Monthly | `ui.neatboutique.jacobi.business.monthly` | $29/month | All paid features | 100/month |
| Yearly | `ui.neatboutique.jacobi.business.yearly` | $290/year | Same as monthly | 100/month |

Prices shown in the app come from the store and can vary by storefront, tax and offer. The yearly saving of $58 is a US list-price comparison, not a guaranteed localized saving. These IDs are configured in `data/config/loci_iap_products.dart`; Android currently queries the same IDs, but its Play products, base plans and offers must be configured and verified separately.

One paid subscription belongs to the owner account and covers all businesses that owner manages. Credits are shared by that owner. Backend must resolve the business's actual owner and authorize the acting user; a manager must not accidentally use their own subscription or gain access to another owner's business. Define how transfers, multiple owners and account deletion are handled before rollout.

| Action | Free / expired | Paid, including cancelled but still entitled |
| --- | --- | --- |
| Browse, community questions/comments, reviews, claim business | Allowed | Allowed |
| Create business events, routes, raffles, business announcements/polls | Blocked | Allowed |
| Submit Spotlight ad | Blocked | Allowed with at least 10 credits |
| Existing content and claimed businesses | Preserved and publicly available under their ordinary visibility rules | Preserved |

Enforce these rules on the server for every relevant creation path, including alternate APIs. Export restrictions were included in the draft but are not part of the supplied plan description; confirm the product policy and actual routes before enforcing them. Editing, deleting and moderation of existing content also need explicit product decisions. Do not infer that every activity is business-owned without checking the actual request and authorization model.

## What Flutter currently does

- `SubscriptionController` loads store products, initiates purchases, listens to purchase updates and supports restore. Paid prices are store-provided; free creates no transaction.
- **Release blocker:** its `verifyPurchase` callback always returns true. `lastProcessedPlan` is local feedback, not an entitlement. No purchase is sent to a backend or linked to a Loci account. `IapService` completes successful transactions after that callback, and also completes a transaction when verification returns false; retryable verification failures require a different completion strategy.
- `SubscriptionRepository` calls `GET` and `DELETE /subscriptions/my?businessId=...`. `MySubscriptionController` selects the first business, and clears the displayed subscription immediately after DELETE. Comments describe per-business subscriptions. This conflicts with the proposed owner scope and store cancellation behavior; both client and backend need migration and compatibility planning. Existing model includes Stripe fields and considers only `status == active` active.
- `UpgradeRequiredSheet` matches text passed through `SnackbarService.errorInterceptor`; it does not intercept every HTTP 403 or structured error automatically. Confirm each feature's error path. Prefer structured error codes in a future client update, preserving compatible messages during migration.
- The local plan catalog describes paid features and 100 credits, but it is not proof of backend enforcement or credit accounting. Existing README likewise says IAP is not connected to account status.

## Required purchase and restore flow

1. Authenticate the Loci user and establish a stable store-to-account association before purchase (Apple app account token / Google obfuscated account identifier where supported). Define a recovery process for old purchases without an association. Never silently transfer a purchase already bound to another Loci account.
2. On purchased or restored events, send the platform-specific purchase evidence to the authenticated backend. Treat pending purchases as pending, never as paid. Persist/retry verification across app restarts and network failures; do not show success or grant access on local store feedback alone.
3. Backend validates evidence with the appropriate store, checks app identity, environment, product allowlist, purchase state, expiry, revocation and account binding. Use store-supplied transaction dates and current status, not client dates or a product ID suffix. Atomically persist the verified transaction, entitlement and initial credit grant. Repeated requests and restores must return the same result without duplicate credits.
4. Return the authoritative subscription; client refreshes account status and only then shows unlocked access. Finish/acknowledge the store transaction according to platform requirements after durable processing; distinguish invalid purchases from temporary errors and support retries. Google initial purchases must be acknowledged within the store deadline to avoid refund. Ensure only one component owns acknowledgement.
5. On launch, resume, restore and after returning from store management, refresh backend status. Restore must verify and associate purchases securely; never allocate fresh credits merely because restore was repeated.

## Proposed API contract

All paths below are relative to the configured API base; `/subscriptions/verify` is proposed and is not currently called by Flutter.

`POST /subscriptions/verify`, authenticated JSON: `platform` (`apple` or `google`), `productId`, and platform evidence. For Apple send the transaction ID and, if available, the signed transaction JWS; for Google send the purchase token and product/base-plan identifiers as appropriate. Choose the exact fields based on the installed Flutter billing plugin and platform implementation; a legacy base64 receipt is not interchangeable with a JWS or Google token. The server treats all client fields as untrusted. Return `200` with `{ "success": true, "data": <subscription> }` after durable verification. Return a distinct retryable error for store/network failure and an invalid-purchase error for rejected evidence. Do not log tokens or receipts.

`GET /subscriptions/my?businessId=...` exists in the Flutter client. During migration retain the parameter for compatibility, verify the caller can manage that business, and resolve its owner-level entitlement. A future account-scoped endpoint can remove the first-business dependency. Return `{ "success": true, "data": null }` for no subscription, or a model with `status`, `planId`, `planName`, `billingType`, `currentPeriodStart`, `currentPeriodEnd`, `cancelAtPeriodEnd`, `heroSpotlightCredits`, and `credits: { total, used, remaining }`. Dates are UTC ISO 8601. `amount` is an integer in minor units and `currency` is a currency code when known; do not invent a charge. Add an explicit entitlement/grace-end field in a coordinated client contract if needed. Existing Flutter only regards `active` as active.

`DELETE /subscriptions/my` is an existing client call, not a store cancellation API. For Apple/Google purchases it must not claim to turn off renewal or set `cancelAtPeriodEnd` without store evidence. Update the client to open the appropriate store subscription management page and refresh status on return. Keep any legacy Stripe cancellation behavior explicitly separated by provider.

## Store verification and lifecycle

**Apple:** use Apple's App Store Server Library to verify JWS signatures and certificate chain, app/bundle identity, environment and production app Apple ID as applicable. Query App Store Server API transaction/subscription status using the verified transaction or original transaction ID and configured credentials. Record original transaction ID, transaction IDs, product, signed dates, expiry, revocation and renewal information. Configure separate sandbox and production App Store Server Notifications V2 HTTPS endpoints. Verify the outer signed payload and nested signed data; deduplicate notification UUIDs, handle out-of-order events using signed dates and reconcile with current store status. A notification may arrive before the client associates its purchase: retain it safely for later reconciliation.

**Google:** verify purchase token using Google Play Developer API `purchases.subscriptionsv2.get`, validate package, product/base plan, entitlement state, expiry and account association; securely store tokens and follow linked purchase tokens for replacements. Configure authenticated Pub/Sub real-time developer notifications (RTDN); the notification signals a change, so query the API for current state. Handle acknowledgement, renewals, cancellation, grace, account hold, expiry, refunds and revocation according to verified state.

For both stores, persist raw event identifiers and normalized state, process idempotently, retry failed processing, and periodically reconcile active/recent subscriptions to recover missed or delayed notifications. Never extend dates by adding a month/year locally. Cancellation disables renewal but leaves access through the verified paid-through date. Billing grace grants access only while the store reports an applicable grace period; billing retry/hold alone is not automatically entitled. Refund or revocation must follow verified store status, including partial or reversed refunds. Evaluate expiry at request time using verified entitlement and grace end, even if a webhook is delayed; reconcile uncertain states with the store. Preserve existing content and ownership after entitlement ends.

## Credits and enforcement

Initial verified paid entitlement grants 100 credits. Each Spotlight ad costs 10; check authorization, entitlement and balance and create the ad and debit in one database transaction with an idempotency key. Concurrent requests must not overspend. Keep an immutable ledger with owner, optional business, grant/debit/expiry, cycle, ad reference, timestamp and unique idempotency key. Grant once per eligible cycle, regardless of repeated verification, restore, webhook or job execution. Balance and ledger must agree.

Define a cycle as one calendar month from the initial entitlement anchor, with end-of-month clamping; yearly plans receive monthly grants while entitlement remains valid. Monthly renewals use verified store periods; grant only once per corresponding cycle. Reset means unused credits expire rather than roll over: record expiry and grant in the ledger. Do not grant beyond paid entitlement; reconcile missed scheduled grants based on the agreed cycle policy. Plan switches, interrupted service, overlapping store subscriptions, refunds and resubscription within a cycle need a documented product decision before implementation; do not automatically issue another 100 on every verification or resubscription.

For protected operations authenticate, authorize the business relationship, resolve its owner, evaluate the owner's verified entitlement, and for ads atomically consume credits. Use `403` with `SUBSCRIPTION_REQUIRED` and a message containing “subscription” for entitlement denial; use `INSUFFICIENT_SPOTLIGHT_CREDITS` and “Insufficient Spotlight credits” for credit denial. Authorization failures must have a separate code and message. Current Flutter relies on message matching only where errors reach its snackbar interceptor.

## Tests and release checklist

These are acceptance tests to implement with the backend and future client changes; they are not tests already passed by this document.

- Verify valid monthly/yearly purchases, wrong app/environment/product, tampered or expired evidence, pending transactions, temporary store outage and account-binding conflicts.
- Repeat verification, restore, notification and scheduled job; assert one entitlement and one grant per cycle. Test notification before account association, duplicated/out-of-order delivery and reconciliation after missed notifications.
- Test two businesses owned by one account, an authorized manager, unrelated user and ownership changes. Verify free and expired creation is denied, paid and cancelled-but-unexpired creation is allowed, and existing content remains visible.
- Test renewal, cancellation and re-enable, expiry without webhook, store grace and grace end, hold, refund/revocation and subsequent recovery using store-derived dates.
- Test 15 credits becoming 5, rejection at 5, concurrent ad submissions, failed ad creation rollback, retry idempotency, shared pool, monthly reset and yearly calendar cycles including month ends.
- Client tests: purchase pending, verified success, rejected evidence, network retry and restart, restore, completion/acknowledgement, account switch, status refresh, correct error sheet routing and store management return. Run iOS sandbox/TestFlight and Play test-track end-to-end scenarios with real server notifications before release.

References: [Apple server notifications](https://developer.apple.com/documentation/appstoreservernotifications/receiving-app-store-server-notifications), [Apple notification signed dates](https://developer.apple.com/documentation/appstoreservernotifications/signeddate), [Google subscription lifecycle](https://developer.android.com/google/play/billing/lifecycle/subscriptions), [Google RTDN setup](https://developer.android.com/google/play/billing/getting-ready).

## Verified request mapping for backend integration

The following routes are used by the Flutter repository; the backend implementation and actual enforcement were not available for inspection. Paths are relative to `/api/v1`.

| Client action | Request used in app | Business identification and integration note |
| --- | --- | --- |
| Create event or route | Multipart `POST /events` or `POST /routes` | `CreateActivityController` sends `organizerBusiness` from route arguments. Validate it server-side and resolve its owner. |
| Create raffle | Multipart `POST /raffles` | The controller sends `sponsor` from the business argument; validate and resolve the sponsor owner. |
| Create business announcement or poll | `POST /community-announcements` | `CommunityRepository` uses this endpoint. Resolve the community and its owning business from validated data; inspect the actual backend schema before choosing the ownership lookup. |
| Submit ad | Multipart `POST /admin/ads/submit` | `SubmitAdRequestModel` sends `businessId` only when present. Require a valid authorized business for this paid operation and coordinate client validation. |
| Claim and browse businesses | `POST /businesses/claim`, `GET /businesses` | These remain free under the product rules. |
| Export | `GET /events/{id}/rsvp/export`, `/events/{id}/checkins/export`, `/routes/{id}/checkins/export`, `/raffles/{id}/participants/export`, `/community-members/{id}/export` | Routes exist in the client, but paid gating is an unresolved product decision. |

A notable UI mismatch: failed activity creation goes through `SnackbarService.warning` in `CreateActivityController`, while the paywall hook is installed on `SnackbarService.error`. A subscription rejection on that path therefore cannot be assumed to show the upgrade sheet. Announcement creation uses `SnackbarService.error`; verify the complete ad path and error propagation as part of integration. Avoid using an entitlement message for an ordinary permission failure.

## Concrete proposed response and data records

Example `GET /subscriptions/my?businessId=...` and successful verification response:

```json
{
  "success": true,
  "data": {
    "status": "active",
    "planId": "monthly",
    "planName": "Monthly",
    "billingType": "monthly",
    "currentPeriodStart": "2026-10-27T10:00:00Z",
    "currentPeriodEnd": "2026-11-27T10:00:00Z",
    "cancelAtPeriodEnd": false,
    "heroSpotlightCredits": 70,
    "credits": { "total": 100, "used": 30, "remaining": 70 }
  }
}
```

Use the same remaining balance in `heroSpotlightCredits` and `credits.remaining` until the legacy field is retired in a coordinated client migration. The example omits `amount` and `currency` because pricing data must be verified before reporting a charge. If no subscription exists, return `data: null`; the UI should distinguish a network failure from no subscription.

Example denial response for a paid action:

```json
{ "success": false, "code": "SUBSCRIPTION_REQUIRED", "message": "An active subscription is required for this action. Please upgrade your plan." }
```

Suggested persistent records, adapted to the backend's existing database: (1) subscription keyed to owner and provider, with product, environment, verified provider identifiers, state, period and renewal flags; (2) uniquely keyed provider transactions with store dates and verification state; (3) notification inbox keyed by provider event ID, with processing status and ordering metadata; (4) credit cycles and immutable ledger entries with unique grant and debit references. Add unique constraints for provider transaction identity, event identity, owner/cycle grant and ad debit. Encrypt sensitive tokens, restrict access, and retain audit information without exposing receipts in logs. Exact storage types should follow the backend rather than assuming SQL or UUID IDs.

## Ordered implementation handoff

1. Agree owner/manager resolution and migrate or coexist with existing per-business/Stripe records without granting duplicate access or deleting history. Confirm the unresolved credit, export and account-transfer policies above.
2. Implement provider verification, transaction/account binding, durable idempotent records and normalized entitlement calculation. Implement the verification and compatible status contracts, then test them against store sandbox data.
3. Implement server notifications, retryable processing and reconciliation; test cancellation, grace, renewal and revocation independently of app usage.
4. Implement the credit ledger and atomic ad submission, then add guards to each mapped backend creation route. Test unauthorized users separately from unpaid users.
5. Update Flutter's verifier, account association, retry and completion behavior; refresh status after verification and restore. Update the success screen, current-subscription cancellation dialog, first-business scoping and activity error routing. The current success screen explicitly says the test purchase has not activated Loci access, and `my_subscription_screen.dart` currently warns that cancellation is immediate; both need revision when integration is built.
6. Run the unit and integration scenarios above, then iOS sandbox/TestFlight end-to-end with real purchase, notification, cancellation and restore; exercise Android on a Play test track once configured. App Store product setup and successful purchase alone do not establish backend verification or entitlement enforcement.
