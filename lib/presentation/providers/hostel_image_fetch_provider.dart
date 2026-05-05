import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/hostel_model.dart';
import '../../services/image_api_service.dart';
import 'service_providers.dart';

final imageApiServiceProvider = Provider<ImageApiService>((ref) {
  return ImageApiService();
});

// ─── In-memory session cache ──────────────────────────────────────────────────
// Tracks hostelIds that have already been fetched this session.
// This is the single source of truth to prevent any re-fetch loops.
// It lives in-memory only, so it resets on every app cold-start (which is fine).
final _fetchedThisSession = <String>{};

// ─── Per-hostel image state ───────────────────────────────────────────────────
// A simple StateProvider per hostelId that holds the resolved image URLs.
// Using hostelId (String) as family arg guarantees stable value equality.
final hostelImageUrlsProvider = StateProvider.family<List<String>, String>((ref, hostelId) {
  return [];
});

// ─── Main fetch trigger ───────────────────────────────────────────────────────
// Returns true once the fetch completes (or is skipped). Using String hostelId
// as the family arg gives Riverpod a stable, equality-safe cache key.
final hostelImageFetchProvider = FutureProvider.family<bool, String>((ref, hostelId) async {
  // If we already fetched this hostel this session, skip entirely.
  if (_fetchedThisSession.contains(hostelId)) {
    return true;
  }

  // Mark as fetched immediately to block any concurrent/re-triggered calls.
  _fetchedThisSession.add(hostelId);

  final imageService = ref.read(imageApiServiceProvider);
  final firestore = ref.read(firestoreServiceProvider);

  // Read the current hostel data once (no watch — avoids rebuild loops).
  // We get it from the hostel stream provider if available, or bail gracefully.
  // The hostel name is passed in via a separate simple provider.
  final hostelName = ref.read(_hostelNameProvider(hostelId));
  final existingUrls = ref.read(hostelImageUrlsProvider(hostelId));

  if (existingUrls.isNotEmpty) {
    // Already have images in state, nothing to do.
    return true;
  }

  try {
    final result = await imageService.fetchHostelImages(hostelName, count: 1);

    if (result.imageUrls.isNotEmpty) {
      // Update the in-memory state so widgets rebuild exactly ONCE with new images.
      ref.read(hostelImageUrlsProvider(hostelId).notifier).state = result.imageUrls;

      // Try to persist to Firestore (best-effort — silently ignore permission errors).
      try {
        await firestore.updateDocument(
          'hostels',
          hostelId,
          {
            'imageUrls': result.imageUrls,
            'imageSourceAPI': result.sourceAPI,
            'imageCacheDate': DateTime.now(),
          },
        );
      } catch (_) {
        // Student doesn't have write permission — that's fine.
        // Images are already in hostelImageUrlsProvider for this session.
      }
    }
  } catch (e) {
    // Remove from session set so a manual refresh can retry later.
    _fetchedThisSession.remove(hostelId);
    // ignore: avoid_print
    print('[ImageFetch] Failed for $hostelName: $e');
  }

  return true;
});

// ─── Helper: hostel name lookup ───────────────────────────────────────────────
// Populated by the widget before triggering the fetch.
final _hostelNameProvider = StateProvider.family<String, String>((ref, hostelId) => '');

// ─── Public helper called by widgets ─────────────────────────────────────────
/// Call this from initState / first build to seed the name and kick off the fetch.
/// Uses ref.read intentionally — no rebuild loop possible.
void triggerHostelImageFetch(WidgetRef ref, HostelModel hostel) {
  // Seed the name so the fetch provider can use it.
  if (ref.read(_hostelNameProvider(hostel.hostelId)).isEmpty) {
    ref.read(_hostelNameProvider(hostel.hostelId).notifier).state = hostel.name;
  }

  // Seed existing Firestore images into state — but only if they look valid.
  // Skip stale picsum / broken unsplash URLs from old fetches.
  final validFirestoreUrls = hostel.imageUrls
      .where((url) => !url.contains('picsum.photos') && !url.contains('placeholder'))
      .toList();

  if (validFirestoreUrls.isNotEmpty &&
      ref.read(hostelImageUrlsProvider(hostel.hostelId)).isEmpty) {
    ref.read(hostelImageUrlsProvider(hostel.hostelId).notifier).state = validFirestoreUrls;
    _fetchedThisSession.add(hostel.hostelId);
    return;
  }

  // Kick off the fetch (will be a no-op if already fetched this session).
  ref.read(hostelImageFetchProvider(hostel.hostelId));
}
