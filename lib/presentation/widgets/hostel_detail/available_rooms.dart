import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/theme/app_colors.dart';

import '../../../../data/models/room_category.dart';
import '../../providers/selected_room_provider.dart';

class AvailableRoomsSection extends ConsumerWidget {
  final List<RoomCategory> rooms;

  const AvailableRoomsSection({super.key, required this.rooms});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (rooms.isEmpty) return const SizedBox.shrink();

    final selectedRoom = ref.watch(selectedRoomProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Text('Available Rooms', style: Theme.of(context).textTheme.titleLarge!),
        ),
        SizedBox(height: 16.0),
        ...rooms.asMap().entries.map((entry) {
          final i = entry.key;
          final room = entry.value;
          final isSelected = selectedRoom?.seaterType == room.seaterType;
          final isFull = room.availableBeds <= 0;

          return FadeInUp(
            duration: const Duration(milliseconds: 280),
            delay: Duration(milliseconds: i * 60),
            child: GestureDetector(
              onTap: isFull ? null : () => ref.read(selectedRoomProvider.notifier).state = room,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                margin: EdgeInsets.fromLTRB(24.0, 0, 24.0, 16.0),
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.accent.withValues(alpha: 0.12)
                      : isFull
                          ? AppColors.surfaceAlt.withValues(alpha: 0.4)
                          : AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.accent
                        : isFull
                            ? AppColors.border.withValues(alpha: 0.4)
                            : AppColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected ? [const BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2))] : null,
                ),
                child: Row(
                  children: [
                    // Room icon + selection indicator
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.accent.withValues(alpha: 0.15)
                            : isFull
                                ? AppColors.textTertiary.withValues(alpha: 0.1)
                                : AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        isSelected ? Icons.bed_rounded : Icons.bed_outlined,
                        color: isSelected
                            ? AppColors.accent
                            : isFull
                                ? AppColors.textTertiary
                                : AppColors.textSecondary,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 16.0),

                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${room.seaterType}-Seater Room',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isFull ? AppColors.textTertiary : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isFull
                                      ? AppColors.error.withValues(alpha: 0.15)
                                      : AppColors.success.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  isFull ? 'Fully Booked' : '${room.availableBeds} beds free',
                                  style: TextStyle(
                                    color: isFull ? AppColors.error : AppColors.success,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Price + selection circle
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Rs. ${room.rent.toInt()}',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: isFull ? AppColors.textTertiary : AppColors.textPrimary,
                          ),
                        ),
                        Text('/month', style: Theme.of(context).textTheme.bodySmall!),
                      ],
                    ),

                    SizedBox(width: 8.0),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? AppColors.accent : AppColors.border,
                          width: isSelected ? 6 : 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
