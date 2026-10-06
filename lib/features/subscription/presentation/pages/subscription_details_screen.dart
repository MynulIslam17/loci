import 'dart:ui' show ImageFilter;

import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/subscription/data/models/store_subscription_plan.dart';
import 'package:loci/features/subscription/presentation/controllers/subscription_controller.dart';
import 'package:loci/features/subscription/presentation/pages/subscription_success_screen.dart';
import 'package:loci/features/subscription/presentation/widgets/subscription_compare_tab.dart';
import 'package:loci/features/subscription/presentation/widgets/subscription_plan_details_tab.dart';
import 'package:loci/routes/app_routes.dart';
import 'package:loci/shared/widgets/custom_button.dart';

/// Owns the tab bar, scroll area, and purchase action for plan confirmation.
class SubscriptionDetailsScreen extends GetView<SubscriptionController> {
  const SubscriptionDetailsScreen({super.key});

  Future<void> _subscribe() async {
    if (controller.selectedPlan.value?.isPaid == false) {
      Get.offAllNamed<void>(AppRoutes.bottomNav);
      return;
    }
    final bool success = await controller.subscribe();
    if (success) Get.off<void>(() => const SubscriptionSuccessScreen());
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colorScheme;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: colors.surface,
        appBar: AppBar(
          backgroundColor: colors.surface,
          centerTitle: true,
          title: Text(
            'Loci Business',
            style: AppTextStyle.textLg(weight: FontWeight.w800),
          ),
        ),
        body: Obx(() {
          final StoreSubscriptionPlan? plan = controller.selectedPlan.value;
          if (plan == null) return const SizedBox.shrink();

          return Column(
            children: <Widget>[
              ColoredBox(
                color: colors.surface,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                  child: Builder(builder: _buildTabs),
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: <Widget>[
                    SubscriptionCompareTab(plans: controller.plans),
                    SubscriptionPlanDetailsTab(plan: plan),
                  ],
                ),
              ),
              _buildPurchaseAction(context, plan),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildTabs(BuildContext context) {
    if (context.isCupertino) {
      final TabController tabs = DefaultTabController.of(context);
      return CupertinoTheme(
        data: CupertinoThemeData(
          brightness: Theme.of(context).brightness,
          primaryColor: context.colorScheme.primary,
        ),
        child: _IosGlassTabSelector(tabs: tabs),
      );
    }

    return Container(
      height: 48,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF0F9),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TabBar(
        indicator: BoxDecoration(
          color: const Color(0xFF0866E8),
          borderRadius: BorderRadius.circular(12),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: const Color(0xFF0866E8).withValues(alpha: .22),
              blurRadius: 9,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorAnimation: TabIndicatorAnimation.elastic,
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF123266),
        dividerColor: Colors.transparent,
        labelStyle: AppTextStyle.textSm(weight: FontWeight.w700),
        tabs: const <Tab>[
          Tab(text: 'Compare Plans'),
          Tab(text: 'Plan Details'),
        ],
      ),
    );
  }

  Widget _buildPurchaseAction(
    BuildContext context,
    StoreSubscriptionPlan plan,
  ) {
    final ColorScheme colors = context.colorScheme;
    final SubscriptionController iap = controller;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(color: colors.outlineVariant.withValues(alpha: .6)),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CustomButton(
                text: plan.isPaid
                    ? 'Subscribe for ${iap.productFor(plan.productId)?.price ?? 'unavailable'}'
                    : 'Continue with Free',
                isLoading: controller.isPurchasing.value,
                onPressed: plan.isPaid && iap.productFor(plan.productId) == null
                    ? null
                    : _subscribe,
                borderRadius: 16,
              ),
              const SizedBox(height: 8),
              Text(
                plan.isPaid
                    ? 'Billed by the App Store or Google Play.'
                    : 'No payment is required for the Free plan.',
                textAlign: TextAlign.center,
                style: AppTextStyle.textXs(color: colors.onSurfaceVariant),
              ),
              if (iap.errorMessage.value != null)
                Text(
                  iap.errorMessage.value!,
                  textAlign: TextAlign.center,
                  style: AppTextStyle.textXs(color: colors.error),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A native iOS 26 glass button that follows the shared TabController.
/// The package does not expose a glass style for CNSegmentedControl.
class _IosGlassTabSelector extends StatelessWidget {
  const _IosGlassTabSelector({required this.tabs});

  final TabController tabs;

  static const List<String> _labels = <String>['Compare Plans', 'Plan Details'];

  @override
  Widget build(BuildContext context) {
    final Color trackColor = CupertinoDynamicColor.resolve(
      CupertinoColors.systemFill,
      context,
    ).withValues(alpha: .32);
    final Color borderColor = CupertinoDynamicColor.resolve(
      CupertinoColors.separator,
      context,
    );
    final Color labelColor = CupertinoDynamicColor.resolve(
      CupertinoColors.label,
      context,
    );
    final Color secondaryLabelColor = CupertinoDynamicColor.resolve(
      CupertinoColors.secondaryLabel,
      context,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: trackColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor.withValues(alpha: .35)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: SizedBox(
              height: 44,
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final double itemWidth =
                      constraints.maxWidth / _labels.length;
                  return AnimatedBuilder(
                    animation: tabs.animation!,
                    builder: (BuildContext context, Widget? child) {
                      final double position = tabs.animation!.value.clamp(
                        0.0,
                        1.0,
                      );
                      final int selectedIndex = position.round();
                      return Stack(
                        children: <Widget>[
                          Positioned(
                            left: position * itemWidth,
                            top: 0,
                            bottom: 0,
                            width: itemWidth,
                            child: IgnorePointer(
                              child: ExcludeSemantics(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(22),
                                  child: CNButton(
                                    label: _labels[selectedIndex],
                                    onPressed: () {},
                                    tint: labelColor,
                                    height: 44,
                                    style: CNButtonStyle.glass,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Row(
                            children: <Widget>[
                              for (
                                int index = 0;
                                index < _labels.length;
                                index++
                              )
                                Expanded(
                                  child: Semantics(
                                    selected: index == selectedIndex,
                                    button: true,
                                    child: CupertinoButton(
                                      padding: EdgeInsets.zero,
                                      onPressed: () => tabs.animateTo(index),
                                      child: AnimatedDefaultTextStyle(
                                        duration: const Duration(
                                          milliseconds: 160,
                                        ),
                                        style: CupertinoTheme.of(context)
                                            .textTheme
                                            .textStyle
                                            .copyWith(
                                              color: index == selectedIndex
                                                  ? CupertinoColors.transparent
                                                  : secondaryLabelColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                        child: Text(_labels[index]),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
