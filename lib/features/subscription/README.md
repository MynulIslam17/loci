# Subscription feature

Golden rule: the store says "a purchase happened"; only the backend says
"this account has access". Nothing unlocks from a store callback alone.

| Piece | Role |
|---|---|
| `SubscriptionStatusController` (app-wide) | Server-authoritative status from `GET /subscriptions/my`. Refreshes on login, resume, after verify/restore. A network error keeps the last known status — never shows "free". |
| `SubscriptionController` (app-wide) | Listens to the store purchase stream from app start. Purchase → account token → `POST /subscriptions/verify` → finish the transaction only on `200` or `INVALID_PURCHASE`. Restore. |
| `PendingVerificationQueue` | Secure-storage queue of unverified purchases, keyed by Loci user id, with backoff (5 s, 30 s, 2 min, 10 min, then next launch). Retried on launch, resume and when connectivity returns. |
| `IapService` (`core/iap`) | Thin store wrapper. Never completes on pending/retryable. Android plan switch uses `ChangeSubscriptionParam`. |
| `UpgradeRequiredSheet` | Paywall / credits sheet, routed by error `code` in `NetworkCaller.onErrorCode` (`SUBSCRIPTION_REQUIRED`, `INSUFFICIENT_SPOTLIGHT_CREDITS`). `BUSINESS_ACCESS_DENIED` is a plain error. Message matching stays as a migration fallback. |
| `MySubscriptionScreen` | Plan, credits (+ reset date), grace-period and "ends on" banners. "Manage subscription" opens the App Store / Google Play — store plans can't be cancelled in-app. |

Product IDs live in `data/config/loci_iap_products.dart`; prices always come
from the store. Spotlight ads send an `Idempotency-Key` that is reused while
the user retries the same form.

The backend contract is in the mobile implementation flow doc
(`src/modules/subscriptions` on the API). Tests: `test/features/subscription/`.
