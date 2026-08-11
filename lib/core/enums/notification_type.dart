enum NotificationType {
  referralReceived('referral_received'),
  referralAccepted('referral_accepted'),
  referralRejected('referral_rejected'),
  meetingRequest('meeting_request'),
  meetingConfirmed('meeting_confirmed'),
  meetingRejected('meeting_rejected'),
  questionAnswered('question_answered'),
  eventRsvp('event_rsvp'),
  raffleCompleted('raffle_completed'),
  newMessage('new_message'),
  businessClaimSubmitted('business_claim_submitted'),
  businessClaimApproved('business_claim_approved'),
  communityMemberInvite('community_member_invite'),
  unknown('');

  const NotificationType(this.value);

  final String value;

  static NotificationType fromString(String? raw) {
    final normalized = raw?.toLowerCase().trim() ?? '';
    for (final type in NotificationType.values) {
      if (type.value == normalized) return type;
    }
    return NotificationType.unknown;
  }

  /// Accept / reject directly on the notification card (via notification action API).
  bool get hasInlineActions => this == NotificationType.communityMemberInvite;

  /// Tap opens another screen where the user can review or respond.
  bool get opensDetailScreen => switch (this) {
        NotificationType.referralReceived ||
        NotificationType.referralAccepted ||
        NotificationType.referralRejected =>
          true,
        NotificationType.meetingRequest ||
        NotificationType.meetingConfirmed ||
        NotificationType.meetingRejected =>
          true,
        NotificationType.newMessage => true,
        NotificationType.eventRsvp => true,
        NotificationType.raffleCompleted => true,
        NotificationType.businessClaimSubmitted ||
        NotificationType.businessClaimApproved =>
          true,
        NotificationType.communityMemberInvite => false,
        NotificationType.questionAnswered => true,
        NotificationType.unknown => false,
      };
}
