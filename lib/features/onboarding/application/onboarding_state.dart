enum NotificationPermissionStatus { idle, granted, denied }

class OnboardingState {
  const OnboardingState({
    this.pageIndex = 0,
    Map<String, String>? selectedHabits,
    this.isSaving = false,
    this.errorMessage,
    this.permissionStatus = NotificationPermissionStatus.idle,
    this.isRequestingPermission = false,
  }) : selectedHabits = selectedHabits ?? const <String, String>{};

  final int pageIndex;
  final Map<String, String> selectedHabits;
  final bool isSaving;
  final String? errorMessage;
  final NotificationPermissionStatus permissionStatus;
  final bool isRequestingPermission;

  bool get hasNotificationChoice =>
      permissionStatus != NotificationPermissionStatus.idle;

  bool get canContinue => selectedHabits.isNotEmpty;

  bool get canFinish => !isSaving && hasNotificationChoice;

  OnboardingState copyWith({
    int? pageIndex,
    Map<String, String>? selectedHabits,
    bool? isSaving,
    String? errorMessage,
    NotificationPermissionStatus? permissionStatus,
    bool? isRequestingPermission,
  }) {
    return OnboardingState(
      pageIndex: pageIndex ?? this.pageIndex,
      selectedHabits: selectedHabits ?? this.selectedHabits,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
      permissionStatus: permissionStatus ?? this.permissionStatus,
      isRequestingPermission:
          isRequestingPermission ?? this.isRequestingPermission,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OnboardingState &&
        other.pageIndex == pageIndex &&
        _mapEquals(other.selectedHabits, selectedHabits) &&
        other.isSaving == isSaving &&
        other.errorMessage == errorMessage &&
        other.permissionStatus == permissionStatus &&
        other.isRequestingPermission == isRequestingPermission;
  }

  @override
  int get hashCode => Object.hash(
    pageIndex,
    Object.hashAll(
      selectedHabits.entries.map(
        (entry) => Object.hash(entry.key, entry.value),
      ),
    ),
    isSaving,
    errorMessage,
    permissionStatus,
    isRequestingPermission,
  );
}

bool _mapEquals(Map<String, String> a, Map<String, String> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (final key in a.keys) {
    if (!b.containsKey(key) || b[key] != a[key]) {
      return false;
    }
  }
  return true;
}
