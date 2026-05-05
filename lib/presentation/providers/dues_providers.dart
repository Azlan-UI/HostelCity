import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/dues_model.dart';
import '../../data/repositories/dues_repository.dart';

final duesRepositoryProvider = Provider<DuesRepository>((ref) {
  return DuesRepository();
});

final studentDuesProvider = StreamProvider.family<List<DuesModel>, String>((ref, studentId) {
  final repository = ref.watch(duesRepositoryProvider);
  return repository.getStudentDues(studentId);
});

final hostelDuesProvider = StreamProvider.family<List<DuesModel>, String>((ref, hostelId) {
  final repository = ref.watch(duesRepositoryProvider);
  return repository.getHostelDues(hostelId);
});

final overdueDuesProvider = StreamProvider.family<List<DuesModel>, String>((ref, hostelId) {
  final repository = ref.watch(duesRepositoryProvider);
  return repository.getOverdueDues(hostelId);
});
