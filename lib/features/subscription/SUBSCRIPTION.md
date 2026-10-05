# Loci subscriptions: current implementation overview

This document describes the subscription behavior implemented in the Loci Flutter client and the server API contract that client calls. It is based on this repository's code. The backend service source is not present in this workspace, so server-side rules below are identified as API behavior or as points that need confirmation from the backend rather than claims about unseen implementation.

## 1. What the subscription products represent

The app does not contain a hard-coded list of plan names, prices, or feature entitlements. It fetches the catalog from the API and renders what it receives. There are two billing categories:

| Category | API value | How the app presents/uses it |
|---|---|---|
| Recurring plan | `monthly` | Shown in the Monthly tab; the card displays monthly pricing and returned feature strings and spotlight credits. |
| One-time purchase / credit pack | `one_time` | Shown in the One Time tab; the card displays a one-time price and returned feature strings and spotlight credits. The UI treats these as additive purchases, not recurring-plan upgrades. |

Each catalog item is parsed from `GET /subscriptions/plans` into these fields:

| Field | Meaning in the client |
|---|---|
| `id` | Identifier sent as `planId` during checkout. |
| `realProductId` | Stripe product identifier. The plan card compares this and `id` to the current subscription's `planId` to decide whether the plan is current. |
| `name` | Display name. |
| `billingType` | `monthly` or `one_time`; unknown values currently default to Monthly in the parser. |
| `amount` | Minor currency units; the card divides by 100 for display. The card currently prefixes `$` regardless of the catalog's `currency` field. |
| `currency` | Parsed from the catalog but not used by the plan card's price display. |
| `heroSpotlightCredits` | Number of credits displayed on the plan card when greater than zero. |
| `features` | Backend-provided strings rendered on the expanded plan card. The client does not map those strings to local feature permissions. |

**Which feature access each plan grants:** the client can show the `features` list and credits attached to each live plan, but it does not define the actual entitlement matrix. It does not know from local code, for example, whether a feature label means unlimited usage, a quota, or a time-limited capability. The backend catalog and the backend's feature checks are authoritative. No plan names, current prices, or exact feature-to-plan assignments can be verified from this Flutter repository alone; inspect the live catalog response and backend configuration for that detail.

Spotlight credits are the one explicit usage balance surfaced in the client. Subscription screens use `credits.remaining` as the spendable pooled balance when present, falling back to `heroSpotlightCredits` if the nested `credits` object is absent. The profile ad flow also displays this balance. A subscription banner says an ad uses five credits; that copy is client UI, while whether and when credits are deducted is enforced by the server and cannot be verified here.

## 2. Who can see and use subscription screens

`AuthController.canAccessSubscription` returns true only for roles `business_owner` and `admin`.

| Role | Subscription entry points |
|---|---|
| `business_owner` | Subscription drawer entry and Settings → My Subscription are shown. |
| `admin` | Same entry points are shown. |
| `user` / other roles | Those entry points are hidden. |

The drawer and settings filters are client-side presentation gates. This repository does not show a route guard protecting every subscription route or prove that the backend independently restricts endpoints by role. A hidden menu item is not server authorization.

The auth controller documents that claiming or creating a business can promote a member to `business_owner`; it has a `refreshUser()` method that updates the reactive role from `GET /auth/me`. This subscription feature itself does not perform the claim. A user without a resolvable business is also blocked by the subscription controllers, even if their role permits the screen.

## 3. Auth token versus subscription entitlement

These are two separate checks:

| Check | What it proves | What it does not prove |
|---|---|---|
| Auth token | The API can identify the signed-in user and apply user-level authorization. The shared `NetworkCaller` adds `Authorization: Bearer <token>` when a token is available. On a 401 it attempts the configured token refresh and retries the request once. | It does not mean the user has paid, has an active subscription, or has enough credits. |
| Subscription / plan entitlement | The user is allowed to perform a plan-limited operation or has a credit balance, according to the server's current subscription and entitlement rules. | It does not replace sign-in or establish the user's identity. |
| App role gate | The Flutter UI shows subscription entry points only to `business_owner` and `admin`. | It does not guarantee a valid token or paid access, and it is not a substitute for backend authorization. |

The common HTTP layer attaches the token to requests when present, including requests that may be public. Therefore, seeing a Bearer header in the client does not prove that a particular endpoint requires login. Whether an endpoint accepts an unauthenticated request is decided by the API. User-specific subscription, checkout, business, and management operations are designed to run in an authenticated session; an absent/expired token can lead to a 401 and the app's refresh/retry or sign-in handling.

### What the repository identifies as subscription-sensitive

The upgrade-sheet code explicitly gives creating events, routes, and raffles and credit-limit failures as examples of operations that can be rejected by subscription entitlements. The subscription UI also surfaces spotlight credits, and the business ad submission flow sends a `businessId` so the backend can charge the relevant ad credits. These are the client-visible indicators; the subscription module does not locally check the active plan before those feature calls.

| Operation / capability | Auth token | Subscription or credits | Evidence and limit |
|---|---|---|---|
| View plans / current subscription | Sent when available; user-specific calls rely on a signed-in account. | The catalog can be viewed without already having a paid plan; `/my` reports the current state. | Client repository calls `/subscriptions/plans` and `/subscriptions/my`; backend authentication policy is not in this repo. |
| Buy, upgrade, or cancel a plan | Yes in the normal app session. | A selected plan is the purchase; cancellation changes that state. A role-allowed user and resolvable business are also required by the current client flow. | Subscription controller and common authenticated network layer. |
| Create events, routes, or raffles | Expected to be an authenticated business action. | The paywall implementation cites these as examples of subscription-rejected actions. The exact plan/limit for each is not encoded in Flutter. | `UpgradeRequiredSheet` documentation plus generic message matching; backend guard and precise entitlement are unverified. |
| Create/submit business spotlight ad | Authenticated business action. | The UI displays available spotlight credits; request includes a business id, and server may reject/deduct credits. The cost and deduction timing are not enforced locally here. | Ad submit model/controller and subscription credit display. |
| Other features shown in a plan's `features` array | Depends on the endpoint; common requests attach a token if available. | The feature is subscription-dependent only if the server's entitlement config says so. | Dynamic catalog labels are presentation data; no local feature-to-plan map exists. |

The code does not support a truthful complete matrix such as “Feature A needs only a token; Feature B needs Plan X.” It contains no endpoint-level `requiresSubscription` metadata or full entitlement map. To complete that matrix, pair the backend's plan/feature configuration and route guards with the API endpoints they protect. The mobile client currently relies on backend responses and, for the upgrade sheet, guesses from error-message wording.

## 4. Screens and where the user sees status

### Subscription Plan

The drawer's Subscription entry opens the plan screen. On entry it resets the selector to Monthly. The screen fetches the selected plan category, shows a shimmer until both plans and current subscription status have loaded, and displays the active plan banner when `/subscriptions/my` returns a subscription. The Monthly / One Time toggle is pinned while scrolling. Pull-to-refresh clears the plan cache and reloads the selected category.

Plan cards show the server-provided name, amount, billing type, credit count, and feature strings. Expanding a card reveals its feature list. Button states are:

- `Current Plan` when the current subscription is active and its plan id matches the catalog item (a zero-amount plan is matched by amount).
- `Scheduled` on the pending target plan when `/my` has a matching `pendingPlanId`; the card gives `currentPeriodEnd` as the start date when parseable.
- `Subscribe` or `Join Free` for other plans.
- A spinner on the active card while checkout runs; other purchase buttons are disabled until it completes.

The plans controller caches results independently for each billing category. The plan and checkout controllers are registered permanently through `DrawerBindings`, so revisiting the page can reuse their state. That also means the current-subscription view may be stale until a purchase/cancel refresh, app lifecycle reinitialization, or other explicit fetch. `My Subscription` is a separate per-route screen and fetches when opened.

### My Subscription

Settings → My Subscription shows the returned plan name/status, price and billing period, credit usage (`total`, `used`, `remaining`) when provided, and billing-period dates. Pull-to-refresh fetches again. A null subscription renders an empty state and a link to plans. The screen has a cancel button only when `status == active`.

### Status and price display details

The model understands statuses such as `active`, `past_due`, and `incomplete`. The plan banner has specific labels for those three and otherwise displays the raw status. Money in the subscription detail model is also treated as minor units and divided by 100. The banner and detail screen show `currentPeriodEnd` as a renewal date when available; the UI does not derive access rights from the date.

## 5. Business identifier used by these flows

Before checkout, status lookup, or cancellation, the active controllers call `GET /businesses/me`, parse the list, and use the **first** business id. They cache that id in their controller. There is no business picker in the active plan-screen flow. `POST /subscriptions/checkout` receives `{ planId, businessId }`; `GET /subscriptions/my` and `DELETE /subscriptions/my` receive `?businessId=...`.

The UI is presented as one subscription area, but the API requests are business-id-bearing. The Flutter client alone cannot establish whether the server treats entitlements as account-wide, business-scoped, or uses the business id only as context. For multi-business owners, the current plan page and My Subscription page both act on the first business returned by `/businesses/me`; the user cannot choose another business on these screens.

If `/businesses/me` fails or returns no businesses, checkout stops with a business-required error. Subscription lookup silently returns without replacing the current state when it cannot resolve a business. My Subscription instead shows an error that a business is needed. Cancellation also stops when no business is available.

## 6. End-to-end purchase and validation flow

### A. Page and catalog load

1. The subscription page resets the billing toggle to Monthly.
2. `PlansController` requests `GET /subscriptions/plans?billingType=monthly` (or `one_time` after the toggle).
3. `SubscriptionCheckoutController` separately resolves the first business and requests `GET /subscriptions/my?businessId=...`.
4. The repository treats unsuccessful HTTP responses as exceptions. The service parses catalog data and a `data: null` or non-map `/my` data value as no subscription.
5. The UI renders plan cards and, when applicable, the active subscription banner. A plan fetch error gets an error state with retry. A transient `/my` error is swallowed by the checkout controller and leaves its previous state as-is.

### B. User starts checkout

1. The user taps a plan. For a recurring plan whose amount exceeds the active paid plan's amount, the card first asks for confirmation and says an immediate switch may charge a prorated amount. One-time plans skip that upgrade dialog.
2. The controller prevents a second concurrent checkout, resolves/caches the first business id, and calls `POST /subscriptions/checkout` with the selected `planId` and `businessId`.
3. The checkout model accepts aliases for several Stripe fields to handle response-field naming drift. To open PaymentSheet it requires nonempty `customerId`, ephemeral key, and payment-intent client secret; it also reads an optional publishable key and subscription id.
4. The client branches on the response:

| Checkout response marker | Client action |
|---|---|
| `free: true` | Skip Stripe, refetch `/my`, and expect to see an active zero-amount plan. If that did not appear, show an error. |
| `scheduled: true` | Skip Stripe and refetch `/my`. The scheduled plan is represented by `pendingPlanId`/`pendingPlanName` and the period end. |
| `switched: true` without complete PaymentSheet details | Treat as a completed switch, refetch `/my`, and show a success message. |
| Complete PaymentSheet details | Continue to Stripe PaymentSheet, whether this is a new recurring checkout, one-time purchase, or a switch that still needs payment confirmation. |
| Any other/incomplete paid response | Show “Could not start checkout”; no PaymentSheet opens. |

The comments/model describe response shapes for free, new monthly, one-time, upgrade, and scheduled downgrade. The active controller's concrete decision is based on the flags and whether all required PaymentSheet fields exist. It does not validate the plan price or entitlements locally.

### C. Stripe payment

`StripeService` loads a publishable key from `GET /subscriptions/config` unless checkout supplied one, configures the Stripe SDK on iOS/Android, and opens Stripe PaymentSheet. The app uses Stripe's native SDK; the web path does not present PaymentSheet. If a user reaches paid checkout on web, an informational message directs them to the mobile app. A canceled PaymentSheet is silent. Other Stripe errors show their localized message when available, otherwise a payment-failed message.

### D. Confirming activation

After PaymentSheet returns successfully, the controller polls `GET /subscriptions/my` up to eight times, waiting one second between unsuccessful checks. It considers the purchase activated when the returned status is `active`. If it is still not active at the end of polling, the app says payment was received and activation should happen shortly. It does not keep polling in the background or offer an automatic retry action there.

This means payment-sheet completion and entitlement activation are separate moments in the client flow. The app relies on the API to report the resulting subscription on `/my`; Stripe PaymentSheet completion alone is not treated as proof that entitlement is active.

## 7. Upgrades, downgrades, one-time purchases, and cancellation

### Recurring upgrade

The card treats a Monthly plan as an upgrade when there is an active paid plan and the selected plan's amount is higher. It requests confirmation, describing an immediate prorated charge and the future monthly price. The backend response controls whether the app displays a PaymentSheet (`switched` plus payment details) or simply refetches status. The client comment says upgrades can be applied in place with proration. Exact proration, saved-payment-method behavior, invoice handling, and failure recovery are server/Stripe behavior not visible in this repository.

### Recurring downgrade

The client recognizes a scheduled response, makes no PaymentSheet call, and refetches `/my`. When `pendingPlanId` matches a plan, that plan shows `Scheduled` and a start date derived from the current subscription's `currentPeriodEnd`, or “Starts at next renewal” if no usable date exists. The current plan remains the matching active plan in the UI until the API reports otherwise. Canceling or replacing a pending downgrade is not specially implemented in the client; it depends on subsequent checkout/cancel behavior from the API.

### One-time purchase

One-time catalog items use the same checkout endpoint and PaymentSheet field validation. The card does not classify them as recurring upgrades. A checkout response without the necessary Stripe values stops with an error. The status model supports pooled `credits.remaining`, so the UI can display a balance that includes subscription and pack credits if the server returns it. The credit expiry, order of consumption, refund behavior, stacking rules, and whether a one-time purchase appears as a subscription record are not determined by this client code.

### Cancellation

Both the banner and My Subscription screen offer cancellation only when the current model says `active`; free plans are not excluded by that UI check. The confirmation dialog says cancellation is immediate and remaining paid days are not refunded. The controller calls `DELETE /subscriptions/my?businessId=...`.

After a successful request, the plan screen refetches `/my`; the My Subscription screen immediately clears its local subscription and shows its no-subscription state. These are the current client assumptions. The backend implementation is not present here, so the actual effective timestamp, refund policy, Stripe cancellation mode, idempotency, and response semantics need backend verification. `cancelAtPeriodEnd` is parsed from `/my` but is not used to present a scheduled-cancellation state in the current screens.

## 8. Feature access checks and upgrade paywall

The client renders a plan's feature strings but does not implement local feature guards for event, route, raffle, community, export, or other paid actions in this subscription module. Protected operations must be validated by the API that handles each operation; otherwise a user could bypass a client-only check.

When a feature controller passes an error through `SnackbarService.error`, the global error interceptor can replace some backend errors with an upgrade sheet:

1. The message is sanitized and passed to the interceptor.
2. `UpgradeRequiredSheet` looks for terms such as `subscription`, `upgrade`, `plan`, `limit reached`, `active event`, credit-related phrases, or `hero spotlight`.
3. If a term matches, it shows the backend's message plus View plans and Maybe later, unless another sheet is open or the current route is already the plan screen.
4. If no term matches, the regular error snackbar is shown.

This is a **message-text heuristic**, not a structured entitlement response. A backend wording change can cause a paywall miss; an unrelated error containing one of those words can cause a false positive. Errors surfaced through other UI paths or not passed to `SnackbarService.error` will not be intercepted. The sheet itself grants no access and makes no purchase; the server must validate the protected operation.

## 9. Validation responsibilities: what is established here

| Stage | Client behavior verified in this repository | Server behavior not verifiable here |
|---|---|---|
| Catalog | Requests catalog by billing type, parses returned IDs, price, credits, and feature strings. Displays amount divided by 100. | Whether returned prices/plans are enabled, currency/minor-unit conventions for every currency, regional rules, and catalog eligibility. |
| Role/access | Hides drawer/settings entries unless role is `business_owner` or `admin`. | Endpoint authorization and whether an authenticated user can call subscription endpoints directly. |
| Business | Requires `/businesses/me` to return at least one business and sends the first business id. | Ownership validation, allowed business/user relationship, business scoping semantics, and protection from forged ids. |
| Checkout | Sends selected `planId`/business id; branches on response fields; checks for required Stripe client fields before presenting the sheet. | Plan-id validation, amount calculation, Stripe object creation, idempotency, customer ownership, and prevention of price tampering. |
| Payment | Uses Stripe PaymentSheet and waits for `/my` to report active. | Webhook signature verification, payment success/failure reconciliation, retries, delayed payment handling, duplicate events, and activation timing. |
| Entitlements | Shows feature strings and routes some wording-matched errors to the paywall. | Authoritative per-request feature limits, quotas, status checks, credit deduction/atomicity, and behavior after expiration or failed renewal. |
| Cancellation | Sends DELETE and updates local UI after success; dialog claims immediate cancellation/no refund. | Whether cancellation is immediate or period-end, Stripe cancellation result, refunds, credits treatment, and retry/idempotency. |

The authoritative entitlement validation should be performed by the backend on every protected write/action, based on the authenticated user, the applicable business/subscription, current status/period, plan feature/limit, and remaining credits. That is a security requirement for this design, not proof that every listed check currently exists. The backend source or API tests are needed to confirm each check and its exact error/status response.

## 10. Failure and edge cases visible in the app

| Condition | Current client outcome |
|---|---|
| No business or business lookup failure before checkout | Checkout does not start; user sees a business-required error. |
| No business during plan status lookup | Checkout controller leaves its current subscription value unchanged; initial load ends. My Subscription shows a business-required error. |
| Plan catalog request fails | Plan screen shows an error with retry. |
| `/my` returns `data: null` or non-map data | Treated as no subscription. |
| `/my` fails during polling | Poll method catches the error and retains prior local state; later attempts continue. |
| Checkout API fails | Error message is shown via the snackbar service. |
| Checkout response misses required Stripe fields | Checkout stops with “Could not start checkout.” |
| Stripe config missing/invalid | PaymentSheet cannot be started; user gets an error. |
| User closes PaymentSheet | No error is shown; the purchase controller unlocks. There is no client follow-up lookup in this cancellation branch. |
| Payment succeeds but subscription is not active within about eight seconds | Informational “Almost there” message; no background polling. |
| Repeated purchase tap | Ignored while a plan is already processing. |
| Cancel request fails | Error snackbar; current plan state is retained. |
| Offline generic network failure | Some network errors are suppressed when the connectivity service already reports offline. |
| Unknown billing type | Model currently interprets it as Monthly. |
| Invalid/missing dates | Date labels are omitted or fall back to “Starts at next renewal.” |
| Unrecognized subscription status | Banner displays the raw status; cancellation button only appears for exact `active`. |
| Web paid checkout | A `switched` response without PaymentSheet details is handled before the web guard; otherwise paid checkout is blocked with a mobile-app information message. |

Unspecified by the client and requiring backend/Stripe confirmation: duplicate checkout submissions across devices, a user closing the app after payment, webhook delay beyond polling, card authentication/delayed payment states, charge succeeds but activation fails, payment fails after a pending downgrade, cancellation racing renewal, retries after a timeout where the server may have completed the operation, refunds/disputes, and reconciliation of credits after refunds/cancellation.

## 11. API endpoints and response data consumed

All URLs are under the configured API base URL (`/api/v1`). The current base constant points at `https://api.lociapp.io/api/v1`.

| Method and path | Purpose / client behavior |
|---|---|
| `GET /subscriptions/config` | Reads `data.publishableKey` for Stripe setup. |
| `GET /subscriptions/plans?billingType=monthly\|one_time` | Returns the dynamic catalog. |
| `POST /subscriptions/checkout` | Body `{ "planId": "...", "businessId": "..." }`; response is parsed as checkout data. |
| `GET /subscriptions/my?businessId=...` | Returns subscription data; null/non-map `data` means no subscription to the client. |
| `DELETE /subscriptions/my?businessId=...` | Requests cancellation. |
| `GET /businesses/me` | Used to resolve the first business id. |

Fields consumed from `/my` include `status`, `planId`, `planName`, `amount`, `currency`, `billingType`, `currentPeriodStart`, `currentPeriodEnd`, `cancelAtPeriodEnd`, `heroSpotlightCredits`, `credits { total, used, remaining }`, and `pendingPlanId`/`pendingPlanName`. Missing numeric values default to zero in the model, so a malformed response can look like a free/zero-credit plan in some UI elements.

## 12. Source map and implementation notes

| Concern | Main source files |
|---|---|
| Role gate and business context | `features/auth/presentation/controllers/auth_controller.dart`, `features/main_nav/presentation/widgets/app_navigation_drawer.dart`, `features/profile/presentation/pages/settings_screen.dart` |
| URLs, HTTP, parsing | `core/constants/app_url.dart`, `features/subscription/data/repositories/subscription_repository.dart`, `features/subscription/domain/services/subscription_service.dart`, `features/subscription/data/models/` |
| Catalog and checkout | `features/subscription/presentation/controllers/plans_controller.dart`, `features/subscription/presentation/controllers/subscription_checkout_controller.dart`, `features/subscription/presentation/widgets/plan_card.dart` |
| Status and cancellation UI | `features/subscription/presentation/controllers/my_subscription_controller.dart`, `features/subscription/presentation/widgets/active_plan_banner.dart`, `features/subscription/presentation/pages/my_subscription_screen.dart` |
| Stripe | `core/services/stripe/stripe_service.dart` |
| Entitlement error display | `core/utils/show_snackbar.dart`, `features/subscription/presentation/widgets/upgrade_required_sheet.dart` |

There is also a legacy `SubscriptionController` registered by the subscription route binding and used by login code to initialize Stripe. Its purchase/cancellation methods overlap with the active checkout controller, but the subscription plan screen uses `SubscriptionCheckoutController`. For questions about the plan page flow, the latter is the relevant controller.

### Backend confirmation needed for a fully authoritative access matrix

To turn the catalog's feature strings into a definitive “plan X grants capability Y up to limit Z” table and to document backend validation as implemented, inspect the backend subscription/checkout controllers and services, Stripe webhook handlers, entitlement guards/middleware, and the API tests. Those files are not part of this workspace.
