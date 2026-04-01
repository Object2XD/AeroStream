enum NotificationPermissionState {
  granted,
  denied,
  permanentlyDenied,
  unsupported,
  notRequired,
}

extension NotificationPermissionStateX on NotificationPermissionState {
  bool get isAllowed =>
      this == NotificationPermissionState.granted ||
      this == NotificationPermissionState.notRequired;
}
