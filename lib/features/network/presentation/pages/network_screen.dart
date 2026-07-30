import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/network/data/models/dashboard_count.dart';
import 'package:loci/features/network/data/models/checkin_item.dart';
import 'package:loci/features/network/presentation/controllers/network_dashboard_controller.dart';
import 'package:loci/features/network/presentation/widgets/network_detail_row.dart';
import 'package:loci/routes/app_routes.dart';
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
        final isLoading = _controller.isLoading;
        final checkIns = _controller.checkins;

        return RefreshIndicator(
          onRefresh: _controller.refreshDashboard,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Text(
                  'Networking Dashboard',
                  style: AppTextStyle.textXl(
                    color: colors.onSurface,
                    weight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Overview of your network activity',
                  style: AppTextStyle.textSm(
                    color: colors.onSurfaceVariant,
                    weight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                if (isLoading) ...[
                  AppSkeleton.grid(context: context),
                  const SizedBox(height: 24),
                  AppSkeleton.list(context: context),
                ] else ...[
                  if (counts != null) _buildStats(context, counts),
                  const SizedBox(height: 24),
                  _buildQuickActions(context),
                  const SizedBox(height: 24),
                  _buildRecentCheckIns(context, checkIns),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStats(BuildContext context, DashboardCounts counts) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.55,
      children: [
        _statCard(context, 'Total Contacts', '${counts.connections}',
            Icons.people_outline, AppRoutes.connection),
        _statCard(context, 'Check-Ins', '${counts.totalCheckIns}',
            Icons.qr_code_scanner_outlined, AppRoutes.checkIn),
        _statCard(context, 'Referrals Sent', '${counts.referralsSent}',
            Icons.send_outlined, AppRoutes.referral),
        _statCard(context, 'Upcoming Meetings', '${counts.upcomingMeetings}',
            Icons.handshake_outlined, AppRoutes.meeting),
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

    return Material(
      color: colors.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => Get.toNamed(route),
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.4),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: colors.primary, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    value,
                    style: AppTextStyle.textXl(
                      color: colors.onSurface,
                      weight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: AppTextStyle.textXs(
                  color: colors.onSurfaceVariant,
                  weight: FontWeight.w500,
                ),
              ),
            ],
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
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => Get.toNamed(AppRoutes.checkIn),
          icon: Icon(Icons.qr_code_scanner_rounded, color: colors.onPrimary),
          label: Text(
            'Check In',
            style: AppTextStyle.textMd(
              weight: FontWeight.w600,
              color: colors.onPrimary,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _actionButton(context, 'Referral', AppRoutes.referral),
            const SizedBox(width: 10),
            _actionButton(context, 'Connection', AppRoutes.connection),
            const SizedBox(width: 10),
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
          padding: const EdgeInsets.symmetric(vertical: 12),
          side: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.6)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyle.textSm(
            color: colors.onSurface,
            weight: FontWeight.w600,
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
        const SizedBox(height: 12),
        if (checkIns.isEmpty)
          EmptyState(
            icon: Icons.qr_code_scanner_outlined,
            title: 'No check-ins yet',
            subtitle:
                'Scan a QR code at an event or route to record your first check-in',
            action: CustomButton(
              onPressed: () => Get.toNamed(AppRoutes.checkIn),
              height: 42,
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
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: checkIns.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.04),
            blurRadius: 8,
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
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomCachedImage(
                isCircle: true,
                width: 40,
                height: 40,
                imageUrl: checkIn.leadData.avatar,
              ),
              const SizedBox(width: 10),
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
                      const SizedBox(height: 4),
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
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                const SizedBox(width: 8),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
