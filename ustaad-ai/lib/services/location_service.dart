import 'dart:math';

/// Mock GPS ping simulator for Ustaad.ai.
///
/// Simulates location tracking by generating coordinates near
/// a central point (Lahore, Pakistan) with slight random offsets.
///
/// // TODO: ANTIGRAVITY HOOK — Replace with real GPS using
/// the `geolocator` package and send pings to ApiEndpoints.locationPing.
class LocationService {
  // Center point: Lahore, Pakistan
  static const double _baseLat = 31.5204;
  static const double _baseLng = 74.3587;
  final Random _random = Random();

  /// Sends a location ping to the backend for a specific job.
  ///
  /// // TODO: ANTIGRAVITY HOOK — Replace with:
  /// ```
  /// final position = await Geolocator.getCurrentPosition();
  /// await http.post(
  ///   Uri.parse(ApiEndpoints.locationPing),
  ///   body: jsonEncode({
  ///     'job_id': jobId,
  ///     'lat': position.latitude,
  ///     'lng': position.longitude,
  ///     'timestamp': DateTime.now().toIso8601String(),
  ///   }),
  /// );
  /// ```
  Future<Map<String, double>> sendLocationPing(String jobId) async {
    // Simulate GPS acquisition delay
    await Future.delayed(const Duration(milliseconds: 800));

    final lat = _baseLat + (_random.nextDouble() - 0.5) * 0.01;
    final lng = _baseLng + (_random.nextDouble() - 0.5) * 0.01;

    print('[LocationService] Job $jobId → GPS ping sent: ($lat, $lng)');

    return {'latitude': lat, 'longitude': lng};
  }

  /// Gets the current mock location.
  ///
  /// // TODO: ANTIGRAVITY HOOK — Replace with real Geolocator call
  Future<Map<String, double>> getCurrentLocation() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final lat = _baseLat + (_random.nextDouble() - 0.5) * 0.01;
    final lng = _baseLng + (_random.nextDouble() - 0.5) * 0.01;

    return {'latitude': lat, 'longitude': lng};
  }
}
