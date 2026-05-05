import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/room_category.dart';

/// Tracks which room category the student has selected on the detail page.
final selectedRoomProvider = StateProvider<RoomCategory?>((ref) => null);
