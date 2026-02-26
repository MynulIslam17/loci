import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/widgets/custom_text_field.dart';

class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({super.key});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Connection',
          style: AppTextStyle.textLg(weight: FontWeight.w700),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // Search Bar using your Custom Widget
            CustomTextField(
              hintText: "Search Connection",
              hintTextColor: context.colorScheme.onSurfaceVariant,
              textColor: context.colorScheme.onSurface,
              suffixIcon: Icon(
                Icons.search,
                color: context.colorScheme.onSurfaceVariant,
              ),
              borderColor: context.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              "Network",
              style: AppTextStyle.textXl(weight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              "5 contacts",
              style: AppTextStyle.textSm(
                  weight: FontWeight.w500,
                  color: context.colorScheme.onSurfaceVariant
              ),
            ),
            const SizedBox(height: 16),
            // Connection List
            Expanded(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  return _buildConnectionCard(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Private Widget Method for the Connection Card
  Widget _buildConnectionCard(BuildContext context) {
    return Card(
      elevation: 2,
      color: context.colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 9),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            const CircleAvatar(

              radius: 26,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12'),

            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Alexandra Broke",
                    style: AppTextStyle.textMd(weight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  _buildInfoRow(context, Icons.business_center_outlined, "VP of Sales at TechCorp"),
                  _buildInfoRow(context, Icons.email_outlined, "sarah.j@techcorp.com"),
                  _buildInfoRow(context, Icons.phone_outlined, "555-0101"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper for the small icon + text rows
  Widget _buildInfoRow(BuildContext context, IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Icon(icon, size: 14, color: context.colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: AppTextStyle.textXs(color: context.colorScheme.onSurfaceVariant),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}