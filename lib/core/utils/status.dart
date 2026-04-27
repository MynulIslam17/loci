enum ReferralStatusEnum { //-- for referralStatus
  sent,
  pending,
  rejected,
  confirm,
}


String getReferralStatus(ReferralStatusEnum status) {
  switch (status) {
    case ReferralStatusEnum.sent:
      return "sent";

    case ReferralStatusEnum.pending:
      return "pending";

    case ReferralStatusEnum.rejected:
      return "rejected";

    case ReferralStatusEnum.confirm:
      return "confirm";
  }
}
