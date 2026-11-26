import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/features/auth/presentation/controllers/auth_controller.dart';
import 'package:loci/features/subscription/presentation/controllers/subscription_status_controller.dart';
import 'package:loci/routes/app_routes.dart';
import 'package:loci/shared/widgets/confirm_dialog.dart';

/// Where the Subscription entry leads. Subscribers go to "My Subscription"
/// (plan, credits, manage); everyone else goes to the plans.
String subscriptionRouteFor(SubscriptionStatusController? status) =>
    status?.subscription.value != null
    ? AppRoutes.mySubscription
    : AppRoutes.subscription;

/// Subscription is shown to everyone but only business owners (and admins)
/// can use it — members see it locked until a business claim is approved.
bool subscriptionLocked(AuthController auth) => !auth.canAccessSubscription;

/// Copy for the locked state (members).
const String subscriptionLockedTitle = 'Unlock Loci Business';
const String subscriptionLockedMessage =
    'Subscriptions are for business owners. Claim your business to unlock '
    'Loci Business plans and Spotlight credits.\n\n'
    'Already submitted a claim? It unlocks automatically as soon as your '
    'claim is approved.';

/// Single entry point for the drawer and Settings.
///
/// * Member: re-checks the role first (a claim may have just been approved),
///   then either opens the plans or explains how to unlock them.
/// * Owner: makes sure the status has loaded (so a subscriber lands on "My
///   Subscription", not the plans), then opens the right screen.
///
/// [context] may already be gone (e.g. the drawer closed); the app's
/// navigator context is used for the dialog then.
Future<void> openSubscription([BuildContext? context]) async {
  final AuthController auth = Get.find<AuthController>();

  if (subscriptionLocked(auth)) {
    await auth
        .refreshUser(force: false)
        .timeout(const Duration(seconds: 3), onTimeout: () => false);
    if (subscriptionLocked(auth)) {
      final BuildContext? dialogContext = (context?.mounted ?? false)
          ? context
          : Get.context;
      if (dialogContext == null || !dialogContext.mounted) return;
      final bool claim = await showConfirmDialog(
        dialogContext,
        title: subscriptionLockedTitle,
        message: subscriptionLockedMessage,
        confirmText: 'Claim my business',
        cancelText: 'Not now',
        icon: Icons.lock_outline_rounded,
      );
      if (claim) Get.toNamed<void>(AppRoutes.searchBusiness);
      return;
    }
  }

  final SubscriptionStatusController? status =
      Get.isRegistered<SubscriptionStatusController>()
      ? Get.find<SubscriptionStatusController>()
      : null;
  if (status != null && !status.hasLoaded.value) {
    await status.reload().timeout(const Duration(seconds: 4), onTimeout: () {});
  }
  Get.toNamed<void>(subscriptionRouteFor(status));
}
