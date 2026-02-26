enum ReferralStatus { //-- for referralStatus
  sent,
  pending,
  rejected,
}


String getReferralStatus(ReferralStatus status){

  switch(status){
    case ReferralStatus.sent : return "sent";
    case  ReferralStatus.pending : return "pending";
    case ReferralStatus.rejected : return "rejected";


  }

}
