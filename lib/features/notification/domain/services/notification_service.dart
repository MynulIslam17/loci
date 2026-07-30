import 'package:loci/features/notification/data/models/notification_response_model.dart';
import 'package:loci/features/notification/data/repositories/notification_repository.dart';

/// Domain orchestration for notifications. Controllers call this — never NetworkCaller.
class NotificationService {
  final NotificationRepository _repository;

  NotificationService(this._repository);

  Future<NotificationResponseModel> getNotifications({
    required int page,
    required int limit,
  }) async {
    final body = await _repository.getNotifications(page: page, limit: limit);
    return NotificationResponseModel.fromJson(body);
  }

  Future<void> performAction({
    required String notificationId,
    required String action,
  }) async {
    await _repository.performAction(
      notificationId: notificationId,
      action: action,
    );
  }
}
