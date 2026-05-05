import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/complaint_repository.dart';
import '../../data/repositories/resident_repository.dart';
import '../../data/repositories/notice_repository.dart';
import '../../data/models/complaint_model.dart';
import '../../data/models/resident_model.dart';
import '../../data/models/notice_model.dart';
import '../../data/models/hostel_model.dart';
import 'service_providers.dart';
import 'hostel_providers.dart';

// Complaint Repository Provider
final complaintRepositoryProvider = Provider<ComplaintRepository>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return ComplaintRepository(firestoreService);
});

// Resident Repository Provider
final residentRepositoryProvider = Provider<ResidentRepository>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return ResidentRepository(firestoreService);
});

// Notice Repository Provider
final noticeRepositoryProvider = Provider<NoticeRepository>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return NoticeRepository(firestoreService);
});

// Complaints by Hostel Provider
final complaintsByHostelProvider = StreamProvider.family<List<ComplaintModel>, String>((ref, hostelId) {
  final repository = ref.watch(complaintRepositoryProvider);
  return repository.getComplaintsByHostel(hostelId);
});

// Residents by Hostel Provider
final residentsByHostelProvider = StreamProvider.family<List<ResidentModel>, String>((ref, hostelId) {
  final repository = ref.watch(residentRepositoryProvider);
  return repository.getActiveResidentsByHostel(hostelId);
});

// Notices by Hostel Provider
final noticesByHostelProvider = StreamProvider.family<List<NoticeModel>, String>((ref, hostelId) {
  final repository = ref.watch(noticeRepositoryProvider);
  return repository.getNoticesByHostel(hostelId);
});

// Pending Complaints Count Provider
final pendingComplaintsCountProvider = FutureProvider.family<int, String>((ref, hostelId) {
  final repository = ref.watch(complaintRepositoryProvider);
  return repository.getPendingComplaintsCount(hostelId);
});

// Active Residents Count Provider
final activeResidentsCountProvider = FutureProvider.family<int, String>((ref, hostelId) {
  final repository = ref.watch(residentRepositoryProvider);
  return repository.getActiveResidentsCount(hostelId);
});

// Hostels by Admin Provider (auth + token refresh before stream — matches approved hostels fix)
final hostelsByAdminProvider = StreamProvider.family<List<HostelModel>, String>((ref, adminId) {
  final repository = ref.watch(hostelRepositoryProvider);
  return FirebaseAuth.instance.authStateChanges().asyncExpand((user) async* {
    if (user == null || user.uid != adminId) {
      yield <HostelModel>[];
      return;
    }
    try {
      await user.getIdToken(true);
    } catch (_) {}
    yield* repository.getHostelsByAdmin(adminId);
  });
});
