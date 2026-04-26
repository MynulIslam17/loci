import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';

import 'package:loci/presentation/widgets/custom_image_container.dart';
import 'package:loci/presentation/widgets/custom_text_field.dart';

import '../../../core/enums/network_type.dart';
import '../../../data/models/network/connection_item.dart';
import '../../controllers/network_dash/connection_controller.dart';

class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({super.key});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  final controller = Get.find<ConnectionController>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchDashboard(NetworkType.connections);
    });
  }

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
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: GetBuilder<ConnectionController>(
          builder: (controller) {
            final connectionList = controller.connections;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                CustomTextField(
                  hintText: "Search Connection",
                  suffixIcon: Icon(Icons.search),
                  borderColor: context.colorScheme.outline,
                ),

                const SizedBox(height: 16),

                Text(
                  "Network",
                  style: AppTextStyle.textXl(weight: FontWeight.w600),
                ),

                const SizedBox(height: 4),

                Text(
                  "${connectionList.length} contacts",
                  style: AppTextStyle.textSm(
                    weight: FontWeight.w500,
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 16),

                Expanded(
                  child: controller.isLoading
                      ? const Center(
                    child: CircularProgressIndicator(),
                  )
                      : connectionList.isEmpty
                      ? Center(
                    child: Text(
                      "No connections found",
                      style: AppTextStyle.textSm(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                      : ListView.builder(
                    itemCount: connectionList.length,
                    itemBuilder: (context, index) {
                      final connection = connectionList[index];
                      return _buildConnectionCard(context, connection);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }


  Widget _buildConnectionCard(
      BuildContext context,
      ConnectionModel connection,
      ) {
    return Card(
      elevation: 2,
      color: context.colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: Row(
          children: [
            CustomCachedImage(
              width: 60,
              height: 60,
              imageUrl: connection.avatar,
              isCircle: true,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    connection.name,
                    style: AppTextStyle.textMd(weight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),

                  _buildInfoRow(
                    context,
                    Icons.business_center_outlined,
                    connection.organization,
                  ),
                  _buildInfoRow(
                    context,
                    Icons.email_outlined,
                    connection.email,
                  ),
                  _buildInfoRow(
                    context,
                    Icons.phone_outlined,
                    connection.phone.isEmpty
                        ? "No phone"
                        : connection.phone,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle.textXs(),
            ),
          ),
        ],
      ),
    );
  }
}