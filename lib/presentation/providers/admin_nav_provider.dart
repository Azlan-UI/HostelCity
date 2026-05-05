import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Active tab for [AdminShellScreen] (drawer + bottom nav).
final adminNavIndexProvider = StateProvider<int>((ref) => 0);
