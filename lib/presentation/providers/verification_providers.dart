import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/verification_repository.dart';
import '../../data/models/user_model.dart';
import '../../domain/enums/verification_enums.dart';

final verificationRepositoryProvider = Provider((ref) => VerificationRepository());

final pendingVerificationsProvider = StreamProvider<List<UserModel>>((ref) {
  return ref.watch(verificationRepositoryProvider).getUsersByVerificationStatus(VerificationStatus.pending);
});

final approvedVerificationsProvider = StreamProvider<List<UserModel>>((ref) {
  return ref.watch(verificationRepositoryProvider).getUsersByVerificationStatus(VerificationStatus.approved);
});

final rejectedVerificationsProvider = StreamProvider<List<UserModel>>((ref) {
  return ref.watch(verificationRepositoryProvider).getUsersByVerificationStatus(VerificationStatus.rejected);
});

final verificationStatsProvider = FutureProvider<Map<String, int>>((ref) {
  // This is a future provider, will need to be manually refreshed or use a stream if stats are critical
  return ref.watch(verificationRepositoryProvider).getVerificationStats();
});

