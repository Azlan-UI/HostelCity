import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Controls the active tab index in [StudentShellScreen].
/// Used by AppDrawer to switch tabs without pushing a new route.
final studentNavIndexProvider = StateProvider<int>((ref) => 0);
