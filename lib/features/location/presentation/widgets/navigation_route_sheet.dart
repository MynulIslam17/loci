import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/features/location/presentation/controllers/live_navigation_controller.dart';

/// The details scroll with the sheet; the primary navigation action stays put.
class NavigationRouteSheet extends StatelessWidget {
  const NavigationRouteSheet({
    super.key,
    required this.controller,
    required this.scrollController,
  });

  final LiveNavigationController controller;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 18,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: Obx(() {
              final navigating = controller.isNavigating.value;
              final mode = controller.selectedTravelMode.value;
              final distance = controller.remainingDistance.value;
              final duration = controller.estimatedDuration.value;
              final error =
                  controller.locationError.value ?? controller.routeError.value;
              return ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                children: [
                  Center(
                    child: Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colors.onSurface.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    controller.destinationTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (controller.locationLabel?.isNotEmpty == true)
                    Text(
                      controller.locationLabel!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                  if (!navigating) ...[
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _ModeButton(
                          label: 'Walk',
                          icon: Icons.directions_walk,
                          selected: mode == 'walking',
                          onPressed: () =>
                              controller.changeTravelMode('walking'),
                        ),
                        const SizedBox(width: 8),
                        _ModeButton(
                          label: 'Ride',
                          icon: Icons.two_wheeler,
                          selected: mode == 'twoWheeler',
                          onPressed: () =>
                              controller.changeTravelMode('twoWheeler'),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _Metric(
                          label: 'Remaining',
                          value: distance,
                          icon: Icons.route,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _Metric(
                          label: 'Estimated time',
                          value: duration,
                          icon: Icons.schedule,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    mode == 'walking'
                        ? 'Walking routes may miss sidewalks or pedestrian paths. Follow local signs.'
                        : 'Two-wheel routes may miss suitable roads. Follow local signs.',
                    style: TextStyle(
                      fontSize: 11,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      error,
                      style: TextStyle(color: colors.error, fontSize: 13),
                    ),
                  ],
                ],
              );
            }),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Obx(() {
                final navigating = controller.isNavigating.value;
                final loading =
                    controller.isLoading.value ||
                    controller.isRouteLoading.value;
                final error =
                    controller.locationError.value ??
                    controller.routeError.value;
                final canStart = controller.canStart;
                return SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: navigating
                        ? controller.stopNavigation
                        : loading
                        ? null
                        : error != null
                        ? controller.retry
                        : canStart
                        ? controller.startNavigation
                        : null,
                    icon: Icon(
                      navigating
                          ? Icons.stop_rounded
                          : error != null
                          ? Icons.refresh_rounded
                          : Icons.navigation_rounded,
                    ),
                    label: Text(
                      navigating
                          ? 'Stop navigation'
                          : loading
                          ? 'Finding route...'
                          : error != null
                          ? 'Retry route'
                          : 'Start navigation',
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
      const SizedBox(width: 8),
      Flexible(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12)),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    ],
  );
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onPressed,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Expanded(
    child: OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: selected
            ? Theme.of(context).colorScheme.primaryContainer
            : null,
      ),
      icon: Icon(icon, size: 18),
      label: Text(label),
    ),
  );
}
