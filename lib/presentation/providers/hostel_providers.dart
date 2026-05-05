import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../data/models/hostel_model.dart';
import '../../data/models/review_model.dart';
import '../../data/repositories/hostel_repository.dart';
import '../../domain/enums/gender_type.dart';
import '../../domain/enums/user_role.dart';
import 'service_providers.dart';
import 'auth_providers.dart';
import 'hostel_filters_provider.dart';

// Hostel Repository Provider
final hostelRepositoryProvider = Provider<HostelRepository>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return HostelRepository(firestoreService);
});

// All Approved Hostels Stream (waits for auth + fresh token to avoid permission-denied races)
final approvedHostelsProvider = StreamProvider<List<HostelModel>>((ref) {
  final repository = ref.watch(hostelRepositoryProvider);
  return FirebaseAuth.instance.authStateChanges().asyncExpand((user) async* {
    if (user == null) {
      yield <HostelModel>[];
      return;
    }
    try {
      await user.getIdToken(true);
    } catch (_) {}
    yield* repository.getApprovedHostels();
  });
});

// Hostel by ID
final hostelByIdProvider = StreamProvider.family<HostelModel?, String>((ref, hostelId) {
  final repository = ref.watch(hostelRepositoryProvider);
  return repository.streamHostelById(hostelId);
});

// Hostel Reviews
final hostelReviewsProvider = StreamProvider.family<List<ReviewModel>, String>((ref, hostelId) {
  final repository = ref.watch(hostelRepositoryProvider);
  return repository.getHostelReviews(hostelId);
});

// Average Rating
final hostelAverageRatingProvider = FutureProvider.family<double, String>((ref, hostelId) {
  final repository = ref.watch(hostelRepositoryProvider);
  return repository.getAverageRating(hostelId);
});

class SearchFilters {
  final String? province;
  final String? city;
  final String? area;
  final GenderType? genderType;
  final double? minRent;
  final double? maxRent;
  final double? maxDistance; // in km
  final LatLng? userLocation;
  final String? searchQuery;

  SearchFilters({
    this.province,
    this.city,
    this.area,
    this.genderType,
    this.minRent,
    this.maxRent,
    this.maxDistance,
    this.userLocation,
    this.searchQuery,
  });

  SearchFilters copyWith({
    String? province,
    String? city,
    String? area,
    GenderType? genderType,
    double? minRent,
    double? maxRent,
    double? maxDistance,
    LatLng? userLocation,
    String? searchQuery,
  }) {
    return SearchFilters(
      province: province ?? this.province,
      city: city ?? this.city,
      area: area ?? this.area,
      genderType: genderType ?? this.genderType,
      minRent: minRent ?? this.minRent,
      maxRent: maxRent ?? this.maxRent,
      maxDistance: maxDistance ?? this.maxDistance,
      userLocation: userLocation ?? this.userLocation,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  bool get hasFilters =>
      province != null ||
      city != null ||
      area != null ||
      genderType != null ||
      minRent != null ||
      maxRent != null ||
      maxDistance != null ||
      (searchQuery != null && searchQuery!.isNotEmpty);
}

// Search Filters State Notifier
class SearchFiltersNotifier extends StateNotifier<SearchFilters> {
  SearchFiltersNotifier() : super(SearchFilters());

  void setProvince(String? province) {
    state = state.copyWith(province: province);
  }

  void setCity(String? city) {
    state = state.copyWith(city: city);
  }

  void setArea(String? area) {
    state = state.copyWith(area: area);
  }

  void setGenderType(GenderType? genderType) {
    state = state.copyWith(genderType: genderType);
  }

  void setRentRange(double? minRent, double? maxRent) {
    state = state.copyWith(minRent: minRent, maxRent: maxRent);
  }

  void setMaxDistance(double? maxDistance) {
    state = state.copyWith(maxDistance: maxDistance);
  }

  void setUserLocation(LatLng? location) {
    state = state.copyWith(userLocation: location);
  }

  void setSearchQuery(String? query) {
    state = state.copyWith(searchQuery: query);
  }

  void clearFilters() {
    state = SearchFilters();
  }
}

// Search Filters Provider
final searchFiltersProvider = StateNotifierProvider<SearchFiltersNotifier, SearchFilters>((ref) {
  return SearchFiltersNotifier();
});

// Filtered Hostels Provider
final filteredHostelsProvider = Provider<AsyncValue<List<HostelModel>>>((ref) {
  final hostelsAsync = ref.watch(approvedHostelsProvider);
  final filters = ref.watch(hostelFiltersProvider);
  final user = ref.watch(currentUserProvider).value;

  return hostelsAsync.whenData((hostels) {
    var filtered = hostels;

      // Filter by student gender
      if (user?.role == UserRole.student && user?.gender != null) {
        filtered = filtered.where((h) => 
          h.genderType == user!.gender
        ).toList();
      }

      // Filter by location (city or area)
      if (filters.location != null && filters.location!.isNotEmpty) {
        final loc = filters.location!.toLowerCase();
        filtered = filtered.where((h) => 
          h.city.toLowerCase().contains(loc) || h.area.toLowerCase().contains(loc)
        ).toList();
      }

      // Filter by rent range
      if (filters.priceMin != null) {
        filtered = filtered.where((h) => h.maxRent >= filters.priceMin!).toList();
      }
      if (filters.priceMax != null) {
        filtered = filtered.where((h) => h.minRent <= filters.priceMax!).toList();
      }



      // Filter by search query (name or address)
      if (filters.searchQuery != null && filters.searchQuery!.isNotEmpty) {
        final query = filters.searchQuery!.toLowerCase();
        filtered = filtered.where((h) =>
          h.name.toLowerCase().contains(query) ||
          h.address.toLowerCase().contains(query) ||
          h.city.toLowerCase().contains(query)
        ).toList();
      }

      // Sorting
      switch (filters.sortBy) {
        case 'price_low':
          filtered.sort((a, b) => a.minRent.compareTo(b.minRent));
          break;
        case 'price_high':
          filtered.sort((a, b) => b.minRent.compareTo(a.minRent));
          break;
        case 'rating':
          // Sort by occupancyRate as proxy for popularity/rating if averageRating is async
          filtered.sort((a, b) => b.occupancyRate.compareTo(a.occupancyRate));
          break;
        case 'relevance':
        default:
          // Keep default order
          break;
      }

      return filtered;
  });
});

// View Mode (List or Map)
enum ViewMode { list, map }

final viewModeProvider = StateProvider<ViewMode>((ref) => ViewMode.list);

// Pending Hostels Provider (moved from platform_admin_dashboard_screen.dart)
final pendingHostelsProvider = StreamProvider<List<HostelModel>>((ref) {
  final repository = ref.watch(hostelRepositoryProvider);
  return repository.getPendingHostels();
});
