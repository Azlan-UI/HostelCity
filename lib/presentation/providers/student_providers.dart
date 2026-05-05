import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/hostel_model.dart';
import '../../data/models/resident_model.dart';
import '../../data/models/booking_model.dart';
import '../../data/repositories/resident_repository.dart';
import '../../data/repositories/complaint_repository.dart';
import 'auth_providers.dart';
import 'admin_providers.dart';
import 'hostel_providers.dart';
import 'service_providers.dart';

// residentRepositoryProvider is defined in admin_providers.dart

// Current Resident Profile Provider
final currentResidentProvider = StreamProvider<ResidentModel?>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  
  return userAsync.when(
    data: (user) {
      if (user == null) return Stream.value(null);
      return ref.watch(residentRepositoryProvider).getResidentByUserId(user.userId);
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

// Current Hostel for Resident Provider
final currentHostelProvider = StreamProvider<HostelModel?>((ref) {
  final residentAsync = ref.watch(currentResidentProvider);
  
  return residentAsync.when(
    data: (resident) {
      if (resident == null) return Stream.value(null);
      return ref.watch(hostelRepositoryProvider).streamHostelById(resident.hostelId);
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

// All Active Resident Stays for Current Student
// Automatically backfills resident records from paid bookings if none exist.
final studentResidentsProvider = StreamProvider<List<ResidentModel>>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  
  return userAsync.when(
    data: (user) {
      if (user == null) return Stream.value([]);
      final repo = ref.watch(residentRepositoryProvider);
      final stream = repo.getAllResidentsByUserId(user.userId);
      
      // Listen to the first emission; if empty, try to auto-migrate
      return stream.asyncMap((residents) async {
        if (residents.isNotEmpty) return residents;
        
        // No resident records found — check for paid bookings
        try {
          final bookingsSnap = await FirebaseFirestore.instance
              .collection('bookings')
              .where('studentId', isEqualTo: user.userId)
              .where('status', isEqualTo: 'paid')
              .get();
          
          if (bookingsSnap.docs.isEmpty) return residents;
          
          final firestore = FirebaseFirestore.instance;
          final List<ResidentModel> created = [];
          
          for (var bookingDoc in bookingsSnap.docs) {
            final booking = BookingModel.fromFirestore(bookingDoc);
            
            // Check if a resident record for this booking already exists
            final existingResident = await firestore
                .collection('residents')
                .where('bookingId', isEqualTo: booking.bookingId)
                .where('userId', isEqualTo: user.userId)
                .limit(1)
                .get();
            
            if (existingResident.docs.isNotEmpty) continue;
            
            // Create resident record from booking
            final resident = ResidentModel(
              residentId: '',
              userId: user.userId,
              hostelId: booking.hostelId,
              roomId: 'Allocated',
              bedId: 'Allocated',
              bookingId: booking.bookingId,
              moveInDate: booking.createdAt,
              isActive: true,
              userName: user.name,
              userEmail: user.email,
              userPhone: user.phone,
            );
            
            final docRef = firestore.collection('residents').doc();
            await docRef.set(resident.toFirestore());
            created.add(resident.copyWith(residentId: docRef.id));
          }
          
          return created;
        } catch (e) {
          // If auto-migration fails, just return the empty list silently
          return residents;
        }
      });
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

// Active Stay Selection Provider for Dashboard
final selectedResidentIdProvider = StateProvider<String?>((ref) => null);

// Currently display selecting resident or fallback to first active
final currentResidentDisplayProvider = Provider<ResidentModel?>((ref) {
  final residents = ref.watch(studentResidentsProvider).value ?? [];
  final selectedId = ref.watch(selectedResidentIdProvider);
  
  if (residents.isEmpty) return null;
  if (selectedId == null) return residents.first;
  
  return residents.firstWhere(
    (r) => r.residentId == selectedId,
    orElse: () => residents.first,
  );
});

// Student's Complaints Provider (across all hostels)
final studentComplaintsProvider = StreamProvider<List>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  
  return userAsync.when(
    data: (user) {
      if (user == null) return Stream.value([]);
      final repository = ref.watch(complaintRepositoryProvider);
      return repository.getComplaintsByUserId(user.userId);
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

