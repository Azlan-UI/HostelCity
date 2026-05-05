enum TargetGroup {
  all,
  floor,
  room;

  String get displayName {
    switch (this) {
      case TargetGroup.all:
        return 'All Residents';
      case TargetGroup.floor:
        return 'Specific Floor';
      case TargetGroup.room:
        return 'Specific Room';
    }
  }
}
