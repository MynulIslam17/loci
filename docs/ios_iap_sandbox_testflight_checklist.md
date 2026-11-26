# iOS subscriptions — local StoreKit, Sandbox & TestFlight checklist

Bundle ID `ui.neatboutique.jacobi` · Team `7CUZU6N28R`
Products: `ui.neatboutique.jacobi.business.monthly` (P1M), `ui.neatboutique.jacobi.business.yearly` (P1Y)

No real money is charged anywhere in this checklist: Xcode StoreKit testing is
local, and every TestFlight / Sandbox-tester purchase is free.

---

## 1. Local StoreKit testing (simulator, done in the app repo)

- `ios/Runner/Loci.storekit` — one group "Loci Business" with monthly ($29.00)
  and yearly ($290.00).
- Attached to the **Run (Debug)** action of the shared `Runner` scheme only.
  Archive/Release (TestFlight, App Store) never uses it.
- It only applies when launched **from Xcode** (⌘R). `flutter run` ignores it.
- Use it to check the **UI**: prices, purchase sheet, pending/cancel states,
  Restore, and in Xcode → Debug → StoreKit → Manage Transactions (refund,
  expire, Ask to Buy, renewal speed-up).
- Expected: the backend **rejects** these purchases (`400 INVALID_PURCHASE`),
  because Xcode signs them locally and Apple can't verify them. That is correct.
  Never relax backend verification to make a local purchase "succeed".

## 2. App Store Connect — products (you)

- [ ] Agreements, Tax and Banking: **Paid Apps** agreement is *Active*.
- [ ] Both products exist as **Auto-Renewable Subscriptions** with exactly the
      IDs above.
- [ ] Both are in the **same subscription group** (Apple handles monthly ↔ yearly).
      Order the group levels (yearly level 1, monthly level 2) if yearly is the upgrade.
- [ ] Durations: monthly = 1 month, yearly = 1 year.
- [ ] Price set for every storefront you sell in (US $29 / $290 or nearest tier).
- [ ] Localization (display name + description) for each product **and** for the group.
- [ ] Review screenshot + review notes on each product.
- [ ] Status is **Ready to Submit** (not "Missing Metadata"). Sandbox and
      TestFlight can buy products in this state.
- [ ] First release: attach both subscriptions to the app version
      ("In-App Purchases and Subscriptions" section) when you submit it.
- [ ] App Information → **App Store Server Notifications V2**:
      Production URL **and** Sandbox URL =
      `https://<api-domain>/api/v1/subscriptions/webhook/apple`.
- [ ] Users and Access → Integrations → **In-App Purchase** key exists (the
      `SubscriptionKey_*.p8`), and the backend has its Key ID, Issuer ID, bundle
      ID and App Apple ID. Keep the .p8 in the backend secret store, not in
      `~/Downloads`.

## 3. Sandbox testers (you)

- [ ] Users and Access → Sandbox → Testers: create 2 testers (A and B), with
      email addresses that are **not** real Apple IDs.
- [ ] On the test iPhone: Settings → App Store → **Sandbox Account** → sign in
      with tester A. Leave the real Apple ID signed in normally.
- [ ] Set the renewal rate for tester A to the fastest (monthly ≈ 5 min,
      yearly ≈ 1 h) to test renewal and expiry.
- [ ] Optional: enable "Interrupted purchase" / Ask to Buy on a tester to test
      the pending path.

## 4. Backend config (backend team)

- [ ] `IAP_ALLOW_SANDBOX=true` on the environment TestFlight points at, until
      App Review approves. Keep it on through review, because reviewers buy in Sandbox.
- [ ] The Apple verifier sends Sandbox transactions to the **Sandbox** App
      Store Server API (`api.storekit-sandbox.itunes.apple.com`). Use
      production-first with a sandbox fallback on "transaction not found" (4040010),
      or route by the JWS `environment` field.
- [ ] The JWS is verified against Apple's root certificate chain (App Store
      Server Library `SignedDataVerifier`), with bundle ID and App Apple ID checked.
- [ ] `appAccountToken` in the signed transaction must equal the caller's
      `/subscriptions/account-token`. Otherwise `409 INVALID_PURCHASE`.
- [ ] Credits are granted in the same DB transaction as the entitlement, using a
      unique key on (originalTransactionId, credit cycle) so retries, restores
      and webhooks can never grant twice.
- [ ] Production billing stays **off** for testing: don't point the app at
      a production API with sandbox disabled to make tests pass.

## 5. TestFlight build (you / Codemagic)

- [ ] Bump `version:` in `pubspec.yaml` (currently `1.9.2+141`).
- [ ] Archive with the **Release** config (`flutter build ipa` or Codemagic
      `ios-release`). The local `.storekit` is not included.
- [ ] Build points at the backend that has `IAP_ALLOW_SANDBOX=true`.
- [ ] Add testers to an internal TestFlight group. TestFlight purchases always
      run in Sandbox and are free.

## 6. Sandbox test plan (TestFlight, tester A unless noted)

For each step, check the app **and** the backend DB / `GET /subscriptions/my`.

| # | Action | Expected |
|---|---|---|
| 1 | Plans screen | Store prices from App Store Connect (not $29.00 from the local file) |
| 2 | Buy **monthly** | Sandbox sheet "[Environment: Sandbox]" → `POST /verify` 200 → success screen → `status active`, `credits 100/100` |
| 3 | DB | One subscription row, `originalTransactionId` stored, `appAccountToken` = user's token, **one** credit grant |
| 4 | Kill app after paying, before verify finishes (airplane mode right after confirming) | Relaunch online → queue verifies → active, still 100 credits |
| 5 | Restore on a fresh install | Same subscription, credits unchanged (no second grant) |
| 6 | Wait one renewal (~5 min) | Webhook `DID_RENEW` → still active, new period end, **new cycle = 100**, unused credits do **not** roll over |
| 7 | Settings → Apple ID → Subscriptions (Sandbox) → cancel | Webhook `DID_CHANGE_RENEWAL_STATUS` → `cancelAtPeriodEnd: true`, app shows "Your plan ends on …", still unlocked |
| 8 | Let it expire | `EXPIRED` → `data: null` → paid actions return `403 SUBSCRIPTION_REQUIRED` (paywall); existing content still visible |
| 9 | Buy **yearly** (or switch from monthly) | Same group → one subscription, plan = yearly, no duplicate credits |
| 10 | Log in as Loci user **B** on the same device / Sandbox account, then Restore | `409 INVALID_PURCHASE` "linked to another Loci account" → stays free |
| 11 | Refund (Sandbox refund request / App Store Connect test notification) | `REFUND` → access revoked |
| 12 | Ask to Buy tester | `PURCHASE_PENDING` → "Waiting for approval…" → approve → active |
| 13 | Spotlight ad with 15 credits | 5 left; next ad → credits sheet; double-tap → one ad, one charge |
| 14 | App Store Connect → "Request a Test Notification" | Backend logs a verified `TEST` notification on the Sandbox URL |
