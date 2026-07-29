# Explore Activity — Private-Visibility Backend Change: App Review

Backend change: PRIVATE events/routes/raffles are now **owner-only** (community members
get 403; admins see all), and private raffles no longer leak into the public list.
No request/response shapes changed. Below is what the Flutter app currently does against
each item in the handoff, and what (if anything) needs editing.

**Status: only ONE change is actually required — item #2 (copy). Everything else is
already correct.**

---

## ✅ Item 1 — Owner dashboard passes `businessId` (THE important one) — CORRECT

The owner "my events / my routes / my raffles" surface is the **Explore Activities**
screen, opened from the owner's own business profile.

- `my_business/.../my_business_profile_body.dart:91` → `Get.toNamed(AppRoutes.exploreActivity,
  arguments: {'businessId': business.id, ...})` — passes the **owner's** business id.
- `explore_activity_screen.dart` reads `businessId` from args and passes it into all three
  tabs (events line 150, routes 151, raffles 152) and every load/search call.
- `business_event_list_controller`, `business_route_list_controller`,
  `business_raffles_list_controller` all take `businessId` as a **required** param and pass
  it to the service on every fetch / loadMore / search.
- `explore_activity_service` → `explore_activity_repository.getEvents/getRoutes/getRaffles`
  all declare `required String businessId` and always put it in `queryParams`.

**Draft-raffle case specifically covered:** the raffles tab goes through
`BusinessRafflesListController.fetchRaffles(businessId: ...)` →
`repository.getRaffles(businessId: ...)`, so the owner dashboard hits OWNER-DASHBOARD mode
and drafts/private/future raffles will be returned. No change needed.

> Note: `businessId` defaults to `''` if the route arg is missing
> (`explore_activity_screen.dart:43`). It is always supplied today (from `business.id`), so
> this is not a live bug — just be aware an empty id would silently fall back to public mode.

---

## ⚠️ Item 2 — Privacy toggle copy — NEEDS CHANGE (only real edit)

`explore_activity/presentation/widgets/explore_activity_visibility_row.dart:43-45`

```dart
isPublic
    ? 'Anyone can discover this activity'
    : 'Only you and invited users',   // <-- now WRONG
```

Private is now **owner-only** — there is no "invited users" audience anymore. The helper
text should say something like **"Only you (the business owner) can see this"**.

- This one widget is used by BOTH the create form (`create_activity_bottom_section.dart:46`)
  and the edit form (`explore_activity_edit_save_section.dart:39`), so a single copy edit
  fixes create and edit together.
- The `Public`/`Private` badge text (`explore_activity_visibility_badge.dart:23`) is fine.
- No other screen describes private as "community members can see it" (checked
  explore_activity / event / community — no such copy exists).

---

## ✅ Item 3 — 403 on detail screens — CORRECT (message displayed directly)

The public / community-facing detail screens are what a non-owner reaches (community
`activity_tab` / `build_activity_content` → `AppRoutes.eventDetails / routeDetails /
rafflesDetails`):

| Screen | Error render | Retry |
|---|---|---|
| `event/.../event_details_screen.dart:110` | `ErrorStateWidget(message: errorMessage)` | ✅ |
| `raffles/.../raffles_details_screen.dart:89` | `ErrorStateWidget(message: errorMessage)` | ✅ |
| `routes/.../route_details_screen.dart:83` | `ErrorStateWidget(message: errorMessage)` | ✅ |
| owner `explore_activity/.../view_activity_screen.dart:22` | `ExploreActivityAsyncBody(errorMessage)` | ✅ |

End-to-end the server `message` is surfaced verbatim:
- repos throw `Exception(res.errorMessage ?? ...)` on non-success
  (event/routes/raffles detail repos),
- controllers store `e.toString()` stripped of the `Exception:` prefix,
- `NetworkCaller._resolveErrorMessage` → `AppErrorMessages.forStatusCode(403,
  serverMessage)` returns `case 403: return cleaned ?? forbidden;` — i.e. the server's
  `"Not authorised to view this event/route/raffle"` is shown directly, not a blank screen
  or generic crash.

No change required. (Optional nicety: on a 403 the `ErrorStateWidget` still shows a "Retry"
button that will just re-fail — harmless, but could be hidden for 403 if desired.)

---

## ✅ Item 4 — Shorter raffle lists for non-owners — CORRECT (no action)

Public raffles browse (`raffles/data/repositories/raffles_repository.getRaffles`) has no
`businessId` param at all — pure public-browse mode — and the UI just renders
`model.raffles`. Nothing caches raffle counts or assumes list length, so fewer raffles
render cleanly.

---

## Summary of edits to make

1. **`explore_activity_visibility_row.dart:45`** — change private helper text from
   `'Only you and invited users'` to owner-only wording (e.g. `'Only you can see this'`).
   Covers both create and edit forms.

Nothing else needs to change — items 1, 3, and 4 are already implemented correctly.
