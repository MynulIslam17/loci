import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/network/data/models/dashboard_count.dart';
import 'package:loci/features/network/data/models/checkin_item.dart';
import 'package:loci/features/network/presentation/controllers/network_dashboard_controller.dart';
import 'package:loci/features/network/presentation/widgets/network_detail_row.dart';
import 'package:loci/routes/app_routes.dart';
import 'package:loci/shared/widgets/adaptive_refresh.dart';
import 'package:loci/shared/widgets/app_skeleton.dart';
import 'package:loci/shared/widgets/custom_button.dart';
import 'package:loci/shared/widgets/custom_image_container.dart';
import 'package:loci/shared/widgets/empty_state.dart';
import 'package:loci/shared/widgets/error_state.dart';

class NetworkScreen extends StatefulWidget {
  const NetworkScreen({super.key});

  @override
  State<NetworkScreen> createState() => _NetworkScreenState();
}

class _NetworkScreenState extends State<NetworkScreen> {
  final _controller = Get.find<NetworkDashboardController>();

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: Obx(() {
        if (_controller.errorMessage != null) {
          return ErrorStateWidget(
            message: _controller.errorMessage!,
            onRetry: _controller.fetchDashboard,
          );
        }

        final counts = _controller.counts;
        final showShimmer = _controller.showInitialShimmer;
        final checkIns = _controller.checkins;

        return AdaptiveRefresh(
          onRefresh: _controller.refreshDashboard,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  'Networking Dashboard',
                  style: AppTextStyle.textXl(
                    color: colors.onSurface,
                    weight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Overview of your network activity',
                  style: AppTextStyle.textSm(
                    color: colors.onSurfaceVariant,
                    weight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                if (showShimmer)
                  _buildDashboardShimmer(context)
                else ...[
                  if (counts != null) _buildStats(context, counts),
                  const SizedBox(height: 10),
                  _buildQuickActions(context),
                  const SizedBox(height: 10),
                  _buildRecentCheckIns(context, checkIns),
                ],
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDashboardShimmer(BuildContext context) {
    final colors = context.colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Stats Row Shimmer (1 row x 4 responsive columns)
        Row(
          children: [
            Expanded(child: _shimmerStatCard(colors, isDark)),
            const SizedBox(width: 8),
            Expanded(child: _shimmerStatCard(colors, isDark)),
            const SizedBox(width: 8),
            Expanded(child: _shimmerStatCard(colors, isDark)),
            const SizedBox(width: 8),
            Expanded(child: _shimmerStatCard(colors, isDark)),
          ],
        ),
        const SizedBox(height: 12),

        // 2. Quick Actions Shimmer
        AppSkeleton.box(width: 100, height: 14, radius: 4),
        const SizedBox(height: 6),
        AppSkeleton.box(width: double.infinity, height: 40, radius: 10),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(child: AppSkeleton.box(height: 38, radius: 10)),
            const SizedBox(width: 8),
            Expanded(child: AppSkeleton.box(height: 38, radius: 10)),
            const SizedBox(width: 8),
            Expanded(child: AppSkeleton.box(height: 38, radius: 10)),
          ],
        ),
        const SizedBox(height: 12),

        // 3. Recent Check-Ins Shimmer
        AppSkeleton.box(width: 120, height: 14, radius: 4),
        const SizedBox(height: 6),
        ListView.separated(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 2,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) => Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: isDark ? 0.3 : 0.4),
                width: 0.6,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.2)
                      : colors.shadow.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AppSkeleton.box(width: 58, height: 18, radius: 6),
                    const Spacer(),
                    AppSkeleton.box(width: 44, height: 10, radius: 4),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSkeleton.box(width: 36, height: 36, radius: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppSkeleton.box(width: 110, height: 12, radius: 4),
                          const SizedBox(height: 4),
                          AppSkeleton.box(width: 140, height: 10, radius: 4),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                AppSkeleton.box(width: double.infinity, height: 28, radius: 8),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _shimmerStatCard(ColorScheme colors, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: isDark ? 0.3 : 0.45),
          width: 0.6,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
                : colors.shadow.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppSkeleton.box(width: 28, height: 28, radius: 8),
          const SizedBox(height: 4),
          AppSkeleton.box(width: 26, height: 14, radius: 4),
          const SizedBox(height: 2),
          AppSkeleton.box(width: 44, height: 9, radius: 3),
        ],
      ),
    );
  }

  Widget _buildStats(BuildContext context, DashboardCounts counts) {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            context,
            'Contacts',
            '${counts.connections}',
            Icons.people_outline_rounded,
            AppRoutes.connection,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _statCard(
            context,
            'Check-Ins',
            '${counts.totalCheckIns}',
            Icons.qr_code_scanner_rounded,
            AppRoutes.checkIn,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _statCard(
            context,
            'Referrals',
            '${counts.referralsSent}',
            Icons.send_rounded,
            AppRoutes.referral,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _statCard(
            context,
            'Meetings',
            '${counts.upcomingMeetings}',
            Icons.handshake_outlined,
            AppRoutes.meeting,
          ),
        ),
      ],
    );
  }

  Widget _statCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    String route,
  ) {
    final colors = context.colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
                : colors.shadow.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () => Get.toNamed(route),
          borderRadius: BorderRadius.circular(14),
          splashColor: colors.primary.withValues(alpha: 0.1),
          highlightColor: colors.primary.withValues(alpha: 0.05),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: isDark ? 0.3 : 0.45),
                width: 0.6,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: isDark ? 0.18 : 0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(icon, color: colors.primary, size: 15),
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    maxLines: 1,
                    style: AppTextStyle.textSm(
                      color: colors.onSurface,
                      weight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: AppTextStyle.textXs(
                      color: colors.onSurfaceVariant,
                      weight: FontWeight.w600,
                    ).copyWith(
                      fontSize: 10.5,
                      letterSpacing: -0.1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final colors = context.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: AppTextStyle.textMd(
            color: colors.onSurface,
            weight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        ElevatedButton.icon(
          onPressed: () => Get.toNamed(AppRoutes.checkIn),
          icon: Icon(Icons.qr_code_scanner_rounded, color: colors.onPrimary, size: 18),
          label: Text(
            'Check In',
            style: AppTextStyle.textSm(
              weight: FontWeight.w600,
              color: colors.onPrimary,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
            minimumSize: const Size(double.infinity, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _actionButton(context, 'Referral', AppRoutes.referral),
            const SizedBox(width: 8),
            _actionButton(context, 'Connection', AppRoutes.connection),
            const SizedBox(width: 8),
            _actionButton(context, 'Meeting', AppRoutes.meeting),
          ],
        ),
      ],
    );
  }

  Widget _actionButton(BuildContext context, String label, String route) {
    final colors = context.colorScheme;

    return Expanded(
      child: OutlinedButton(
        onPressed: () => Get.toNamed(route),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          side: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.6)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            maxLines: 1,
            style: AppTextStyle.textSm(
              color: colors.onSurface,
              weight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentCheckIns(
    BuildContext context,
    List<CheckInModel> checkIns,
  ) {
    final colors = context.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Check-Ins',
          style: AppTextStyle.textMd(
            color: colors.onSurface,
            weight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        if (checkIns.isEmpty)
          EmptyState(
            icon: Icons.qr_code_scanner_outlined,
            title: 'No check-ins yet',
            subtitle:
                'Scan a QR code at an event or route to record your first check-in',
            action: CustomButton(
              onPressed: () => Get.toNamed(AppRoutes.checkIn),
              height: 40,
              child: Text(
                'Check In Now',
                style: AppTextStyle.textSm(
                  weight: FontWeight.w600,
                  color: colors.onPrimary,
                ),
              ),
            ),
          )
        else
          ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: checkIns.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              return _CheckInCard(checkIn: checkIns[index]);
            },
          ),
      ],
    );
  }
}

class _CheckInCard extends StatelessWidget {
  const _CheckInCard({required this.checkIn});

  final CheckInModel checkIn;

  String get _entityLabel {
    if (checkIn.entityName.isNotEmpty) return checkIn.entityName;
    if (checkIn.entityType.isNotEmpty) {
      return checkIn.entityType.replaceAll('_', ' ');
    }
    return 'Unknown location';
  }

  ({String label, IconData icon, Color bg, Color fg}) get _typeStyle {
    switch (checkIn.entityType.toLowerCase()) {
      case 'route':
        return (
          label: 'Route',
          icon: Icons.route_outlined,
          bg: Colors.blue.shade50,
          fg: Colors.blue.shade700,
        );
      case 'event':
        return (
          label: 'Event',
          icon: Icons.event_outlined,
          bg: Colors.green.shade50,
          fg: Colors.green.shade700,
        );
      default:
        return (
          label: 'Check-In',
          icon: Icons.qr_code_scanner_rounded,
          bg: Colors.teal.shade50,
          fg: Colors.teal.shade700,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final type = _typeStyle;
    final name = checkIn.leadData.name.isNotEmpty
        ? checkIn.leadData.name
        : 'Unknown contact';

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _typeBadge(type),
              const Spacer(),
              if (checkIn.timeAgo.isNotEmpty)
                Text(
                  checkIn.timeAgo,
                  style: AppTextStyle.textXs(
                    color: colors.onSurfaceVariant,
                    weight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomCachedImage(
                isCircle: true,
                width: 36,
                height: 36,
                imageUrl: checkIn.leadData.avatar,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      softWrap: true,
                      style: AppTextStyle.textSm(
                        color: colors.onSurface,
                        weight: FontWeight.w600,
                      ),
                    ),
                    if (checkIn.leadData.email.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      NetworkDetailRow(
                        icon: Icons.mail_outline,
                        text: checkIn.leadData.email,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: colors.surfaceContainer,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              children: [
                Icon(type.icon, size: 14, color: type.fg),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _entityLabel,
                    softWrap: true,
                    style: AppTextStyle.textXs(
                      color: colors.onSurfaceVariant,
                      weight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _typeBadge(({String label, IconData icon, Color bg, Color fg}) type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: type.bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(type.icon, size: 12, color: type.fg),
          const SizedBox(width: 4),
          Text(
            type.label,
            style: AppTextStyle.textXs(color: type.fg, weight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
