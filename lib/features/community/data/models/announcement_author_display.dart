import 'package:loci/features/community/data/models/announcement_model.dart';

/// Resolves how a community announcement should show its author in the feed.
class AnnouncementAuthorDisplay {
  const AnnouncementAuthorDisplay({
    required this.displayName,
    required this.avatarUrl,
    required this.isModerator,
    this.businessId,
  });

  final String displayName;
  final String avatarUrl;
  final bool isModerator;
  final String? businessId;

  factory AnnouncementAuthorDisplay.from(
    AnnouncementModel announcement, {
    String? communityOwnerUserId,
  }) {
    if (announcement.displaysAsCommunityBusiness(
      communityOwnerUserId: communityOwnerUserId,
    )) {
      final business = announcement.business!;
      return AnnouncementAuthorDisplay(
        displayName: business.name,
        avatarUrl: business.logo ?? '',
        businessId: business.id,
        isModerator: true,
      );
    }

    final user = announcement.createdBy;
    return AnnouncementAuthorDisplay(
      displayName: user?.name ?? '',
      avatarUrl: user?.avatar ?? '',
      isModerator: false,
    );
  }
}
