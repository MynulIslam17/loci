enum jobStatus {
  pending,
  rejected,
  inProgress,
  completed,
  incompleted,
}


String getJobStatus(jobStatus status){

  switch(status){

    case  jobStatus.pending : return "pending";
    case jobStatus.inProgress : return "in_progress";
    case jobStatus.completed : return "completed";
    case jobStatus.incompleted : return "in_completed";
    case jobStatus.rejected : return "rejected";


  }

}
