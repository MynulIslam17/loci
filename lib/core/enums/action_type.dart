enum ActionType {
  accept,
  reject;

  String get value {
    switch (this) {
      case ActionType.accept:
        return 'accept';
      case ActionType.reject:
        return 'reject';
    }
  }
}