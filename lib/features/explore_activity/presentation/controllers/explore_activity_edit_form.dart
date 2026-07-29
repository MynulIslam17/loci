/// Shared helpers for explore-activity edit forms (event / route / raffle).
///
/// Pattern:
/// - Snapshot server data when the form loads (`_initialData` / `_initialRaffle`).
/// - [hasChanged] compares current UI state to that snapshot.
/// - Update button stays disabled until [hasChanged] is true.
/// - [submit] sends only changed fields (PATCH) and returns early if nothing changed.
library;

/// Trimmed string compare for text fields (hasChanged + PATCH payloads).
bool editFieldChanged(String current, String initial) =>
    current.trim() != initial.trim();

/// Optional guard at the start of [submit].
bool ensureHasChanges({
  required bool hasChanges,
  void Function()? onNoChanges,
}) {
  if (hasChanges) return true;
  onNoChanges?.call();
  return false;
}
