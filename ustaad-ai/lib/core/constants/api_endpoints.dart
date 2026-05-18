/// API endpoint constants for the Antigravity backend.
///
/// // TODO: ANTIGRAVITY HOOK — Replace [baseUrl] with the actual
/// Antigravity Agent endpoint once provisioned.
class ApiEndpoints {
  ApiEndpoints._();

  // TODO: ANTIGRAVITY HOOK — Set this to the real backend URL
  static const String baseUrl = 'https://api.ustaad.ai/v1';

  // ── Job Endpoints ──
  // TODO: ANTIGRAVITY HOOK — Wire to real REST endpoints
  static const String fetchPendingJobs = '$baseUrl/jobs/pending';
  static const String updateJobState = '$baseUrl/jobs/update-state';
  static const String uploadProof = '$baseUrl/jobs/upload-proof';

  // ── Provider (Worker) Endpoints ──
  // TODO: ANTIGRAVITY HOOK — Wire to real REST endpoints
  static const String providerProfile = '$baseUrl/provider/profile';
  static const String providerEarnings = '$baseUrl/provider/earnings';

  // ── Location Ping ──
  // TODO: ANTIGRAVITY HOOK — Wire to real GPS ping webhook
  static const String locationPing = '$baseUrl/location/ping';

  // ── Timeouts ──
  static const Duration requestTimeout = Duration(seconds: 10);
  static const Duration mockDelay = Duration(milliseconds: 1500);
}
