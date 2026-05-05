import 'package:flutter_riverpod/flutter_riverpod.dart';

class HostelFilters {
  final String? location; // city or area
  final double? priceMin;
  final double? priceMax;
  final String sortBy; // 'relevance', 'price_low', 'price_high', 'rating', 'distance'
  final String? searchQuery;

  HostelFilters({
    this.location,
    this.priceMin,
    this.priceMax,
    this.sortBy = 'relevance',
    this.searchQuery,
  });

  HostelFilters copyWith({
    String? location,
    double? priceMin,
    double? priceMax,
    String? sortBy,
    String? searchQuery,
  }) {
    return HostelFilters(
      location: location ?? this.location,
      priceMin: priceMin ?? this.priceMin,
      priceMax: priceMax ?? this.priceMax,
      sortBy: sortBy ?? this.sortBy,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  int countActive() {
    int count = 0;
    if (location != null && location!.isNotEmpty) count++;
    if (priceMin != null || priceMax != null) count++;
    if (sortBy != 'relevance') count++;
    return count;
  }
}

class HostelFiltersNotifier extends StateNotifier<HostelFilters> {
  HostelFiltersNotifier() : super(HostelFilters());

  void setLocation(String? location) {
    state = state.copyWith(location: location);
  }

  void setPriceRange(double? min, double? max) {
    state = state.copyWith(priceMin: min, priceMax: max);
  }

  void setSorting(String sortBy) {
    state = state.copyWith(sortBy: sortBy);
  }

  void setSearchQuery(String? query) {
    state = state.copyWith(searchQuery: query);
  }

  void clearFilters() {
    state = HostelFilters(searchQuery: state.searchQuery); // Preserve search
  }

  void reset() {
    state = HostelFilters(); // Clears everything including search
  }
}

final hostelFiltersProvider = StateNotifierProvider<HostelFiltersNotifier, HostelFilters>((ref) {
  return HostelFiltersNotifier();
});

// Recent searches provider for autocomplete
class RecentSearchesNotifier extends StateNotifier<List<String>> {
  RecentSearchesNotifier() : super([]);

  void addSearch(String search) {
    if (search.trim().isEmpty) return;
    final current = List<String>.from(state);
    current.remove(search);
    current.insert(0, search);
    if (current.length > 6) {
      current.removeLast();
    }
    state = current;
  }
}

final recentSearchesProvider = StateNotifierProvider<RecentSearchesNotifier, List<String>>((ref) {
  return RecentSearchesNotifier();
});
