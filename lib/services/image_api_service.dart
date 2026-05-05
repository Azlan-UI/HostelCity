import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/config/env_config.dart';

class ImageFetchResult {
  final List<String> imageUrls;
  final String sourceAPI;

  ImageFetchResult({required this.imageUrls, required this.sourceAPI});
}

class ImageApiService {
  // Try to fetch images for a hostel with intelligent query generation
  Future<ImageFetchResult> fetchHostelImages(String hostelName, {int count = 3}) async {
    final query = _generateQuery(hostelName);

    try {
      // 1. Primary: Unsplash
      if (EnvConfig.unsplashAccessKey != 'YOUR_UNSPLASH_ACCESS_KEY') {
        final unsplashUrls = await _fetchFromUnsplash(query, count);
        if (unsplashUrls.isNotEmpty) return ImageFetchResult(imageUrls: unsplashUrls, sourceAPI: 'unsplash');
      }
    } catch (e) {
      // Silent error logging, fall through to next
      debugPrint('[ImageAPI] Unsplash fetch failed: $e');
    }

    try {
      // 2. Fallback: Pexels
      if (EnvConfig.pexelsApiKey != 'YOUR_PEXELS_API_KEY') {
        final pexelsUrls = await _fetchFromPexels(query, count);
        if (pexelsUrls.isNotEmpty) return ImageFetchResult(imageUrls: pexelsUrls, sourceAPI: 'pexels');
      }
    } catch (e) {
      debugPrint('[ImageAPI] Pexels fetch failed: $e');
    }

    try {
      // 3. Fallback: Pixabay
      if (EnvConfig.pixabayApiKey != 'YOUR_PIXABAY_API_KEY') {
        final pixabayUrls = await _fetchFromPixabay(query, count);
        if (pixabayUrls.isNotEmpty) return ImageFetchResult(imageUrls: pixabayUrls, sourceAPI: 'pixabay');
      }
    } catch (e) {
      debugPrint('[ImageAPI] Pixabay fetch failed: $e');
    }

    // 4. Zero-key fallback: proven stable Pexels CDN room photos.
    // Only classic IDs from Pexels' earliest content — permanent, CORS-safe.
    const hostelImagePool = [
      'https://images.pexels.com/photos/271624/pexels-photo-271624.jpeg?auto=compress&cs=tinysrgb&w=800', // hotel room
      'https://images.pexels.com/photos/164595/pexels-photo-164595.jpeg?auto=compress&cs=tinysrgb&w=800', // hotel bed
      'https://images.pexels.com/photos/262048/pexels-photo-262048.jpeg?auto=compress&cs=tinysrgb&w=800', // hotel room 2
      'https://images.pexels.com/photos/271639/pexels-photo-271639.jpeg?auto=compress&cs=tinysrgb&w=800', // twin beds
      'https://images.pexels.com/photos/279746/pexels-photo-279746.jpeg?auto=compress&cs=tinysrgb&w=800', // clean room
      'https://images.pexels.com/photos/1457842/pexels-photo-1457842.jpeg?auto=compress&cs=tinysrgb&w=800', // modern room
      'https://images.pexels.com/photos/1643383/pexels-photo-1643383.jpeg?auto=compress&cs=tinysrgb&w=800', // bedroom
      'https://images.pexels.com/photos/2029694/pexels-photo-2029694.jpeg?auto=compress&cs=tinysrgb&w=800', // cosy room
      'https://images.pexels.com/photos/1170412/pexels-photo-1170412.jpeg?auto=compress&cs=tinysrgb&w=800', // study room
      'https://images.pexels.com/photos/1579253/pexels-photo-1579253.jpeg?auto=compress&cs=tinysrgb&w=800', // simple room
    ];
    final seed = hostelName.hashCode.abs();
    // Pick exactly `count` images cycling through the stable pool.
    final selected = List.generate(
      count,
      (i) => hostelImagePool[(seed + i) % hostelImagePool.length],
    );
    return ImageFetchResult(imageUrls: selected, sourceAPI: 'curated');
  }

  String _generateQuery(String name) {
    final lowerName = name.toLowerCase();
    String query = '';
    
    if (lowerName.contains('boys') || lowerName.contains('men')) {
      query = 'male student dormitory bedroom';
    } else if (lowerName.contains('girls') || lowerName.contains('women')) {
      query = 'female student dormitory bedroom';
    } else {
      query = 'hostel dormitory room interior';
    }
    
    // Append part of the name if it's unique enough
    String cleanedName = lowerName;
    const commonTerms = ['hostel', 'pg', 'paying guest', 'housing', 'dorm', 'residency', 'living'];
    for (final term in commonTerms) {
      cleanedName = cleanedName.replaceAll(term, '');
    }
    cleanedName = cleanedName.trim();
    
    if (cleanedName.isNotEmpty) {
      query = '$cleanedName $query';
    }
    
    return Uri.encodeComponent(query);
  }

  Future<List<String>> _fetchFromUnsplash(String query, int count) async {
    final url = Uri.parse('https://api.unsplash.com/search/photos?query=$query&per_page=$count&orientation=landscape&client_id=${EnvConfig.unsplashAccessKey}');
    final response = await http.get(url).timeout(const Duration(seconds: 5));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'] ?? [];
      // Unsplash URLs - use 'regular' size (typically 1080px width)
      return results.map((r) => r['urls']['regular'].toString()).toList();
    }
    return [];
  }

  Future<List<String>> _fetchFromPexels(String query, int count) async {
    final url = Uri.parse('https://api.pexels.com/v1/search?query=$query&per_page=$count&orientation=landscape');
    final response = await http.get(
      url,
      headers: {'Authorization': EnvConfig.pexelsApiKey},
    ).timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List photos = data['photos'] ?? [];
      // Pexels URLs - use 'large' size
      return photos.map((p) => p['src']['large'].toString()).toList();
    }
    return [];
  }

  Future<List<String>> _fetchFromPixabay(String query, int count) async {
    final url = Uri.parse('https://pixabay.com/api/?key=${EnvConfig.pixabayApiKey}&q=$query&per_page=$count&image_type=photo&orientation=horizontal');
    final response = await http.get(url).timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List hits = data['hits'] ?? [];
      // Pixabay URLs - use 'largeImageURL'
      return hits.map((h) => h['largeImageURL'].toString()).toList();
    }
    return [];
  }
}
