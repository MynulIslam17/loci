enum ReferralStatus { //-- for referralStatus
  sent,
  pending,
  rejected,
  confirm,
}


String getReferralStatus(ReferralStatus status) {
  switch (status) {
    case ReferralStatus.sent:
      return "sent";

    case ReferralStatus.pending:
      return "pending";

    case ReferralStatus.rejected:
      return "rejected";

    case ReferralStatus.confirm:
      return "confirm";
  }
}
