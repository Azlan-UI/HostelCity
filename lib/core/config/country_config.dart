import 'package:latlong2/latlong.dart';

class CountryConfig {
  final String name;
  final String code;
  final String currencySymbol;
  final String currencyCode;
  final LatLng defaultLocation;

  const CountryConfig({
    required this.name,
    required this.code,
    required this.currencySymbol,
    required this.currencyCode,
    required this.defaultLocation,
  });

  static const List<CountryConfig> supportedCountries = [
    CountryConfig(
      name: 'Pakistan',
      code: 'PK',
      currencySymbol: 'Rs.',
      currencyCode: 'PKR',
      defaultLocation: LatLng(31.5204, 74.3587), // Lahore
    ),
    CountryConfig(
      name: 'India',
      code: 'IN',
      currencySymbol: '₹',
      currencyCode: 'INR',
      defaultLocation: LatLng(28.6139, 77.2090), // Delhi
    ),
    CountryConfig(
      name: 'United Kingdom',
      code: 'GB',
      currencySymbol: '£',
      currencyCode: 'GBP',
      defaultLocation: LatLng(51.5074, -0.1278), // London
    ),
    CountryConfig(
      name: 'United States',
      code: 'US',
      currencySymbol: '\$',
      currencyCode: 'USD',
      defaultLocation: LatLng(40.7128, -74.0060), // New York
    ),
    CountryConfig(
      name: 'United Arab Emirates',
      code: 'AE',
      currencySymbol: 'AED',
      currencyCode: 'AED',
      defaultLocation: LatLng(25.2048, 55.2708), // Dubai
    ),
  ];

  static CountryConfig fromCode(String code) {
    return supportedCountries.firstWhere(
      (c) => c.code == code,
      orElse: () => supportedCountries.first,
    );
  }
}
