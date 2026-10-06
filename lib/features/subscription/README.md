# Subscription feature

The purchase route uses `SubscriptionController` for plan selection, store
products, purchase events, and restore. The local plan catalog is in
`data/models/store_subscription_plan.dart`; paid prices are read
only from `in_app_purchase`, using IDs in `data/config/loci_iap_products.dart`. The
Free option returns to the app without creating a store transaction.
The same IDs are queried on Android; Google Play must have matching products
before paid Android purchases can work.

`MySubscriptionController` drives the separate My Subscription route. It reads
the existing `/subscriptions/my` API through `SubscriptionService` and
`SubscriptionRepository`. That API has not yet been connected to App Store
transactions, so it may not show a new IAP purchase. Its cancellation action
still applies to subscriptions represented by that API.

Purchase verification in `SubscriptionController` currently accepts store
events for TestFlight testing. The local `lastProcessedPlan` value is not an
account entitlement. Before release, replace the callback with server
verification, synchronize subscription status, and grant account access only
after validation.
