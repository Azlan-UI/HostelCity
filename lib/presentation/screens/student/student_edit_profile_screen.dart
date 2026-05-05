import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/enums/user_role.dart';
import '../../providers/auth_providers.dart';
import '../../widgets/common/app_drawer.dart';
import '../../widgets/common/edit_profile_body.dart';

/// Student dashboard — edit profile (shell tab + drawer).
class StudentEditProfileScreen extends ConsumerWidget {
  const StudentEditProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Error: $e')),
      ),
      data: (user) {
        if (user == null || user.role != UserRole.student) {
          return const Scaffold(
            body: Center(child: Text('Not available')),
          );
        }
        return Scaffold(
          appBar: AppBar(title: const Text('Edit Profile')),
          drawer: const AppDrawer(),
          body: EditProfileBody(
            key: ValueKey(
              '${user.userId}_${user.profileImageUrl}_${user.name}_${user.phone}',
            ),
            user: user,
          ),
        );
      },
    );
  }
}
