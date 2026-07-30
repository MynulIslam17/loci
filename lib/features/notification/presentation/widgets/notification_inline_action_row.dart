import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/enums/action_type.dart';
import 'package:loci/features/notification/data/models/notification_model.dart';
import 'package:loci/features/notification/presentation/controllers/notification_controller.dart';

class NotificationInlineActionRow extends StatelessWidget {
  const NotificationInlineActionRow({
    super.key,
    required this.notification,
  });

  final NotificationModel notification;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationController>();

    return Obx(() {
      final isAccepting = controller.isAccepting(notification.id);
      final isRejecting = controller.isRejecting(notification.id);
      final isBusy = controller.isActingOn(notification.id);

      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: isBusy
                  ? null
                  : () => controller.performAction(
                      notificationId: notification.id,
                      action: ActionType.accept,
                    ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF62B4AC),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isAccepting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Accept',
                      style: AppTextStyle.textSm(
                        color: Colors.white,
                        weight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton(
              onPressed: isBusy
                  ? null
                  : () => controller.performAction(
                      notificationId: notification.id,
                      action: ActionType.reject,
                    ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(vertical: 10),
                side: const BorderSide(color: Colors.redAccent),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isRejecting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.redAccent,
                      ),
                    )
                  : Text(
                      'Reject',
                      style: AppTextStyle.textSm(
                        color: Colors.redAccent,
                        weight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      );
    });
  }
}
