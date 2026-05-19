import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ustaad_ai/models/job_model.dart';
import 'package:ustaad_ai/models/review_model.dart';
import 'package:ustaad_ai/services/api_service.dart';
import 'package:ustaad_ai/services/location_service.dart';

// ─────────────────────────────────────────────
// Service Providers (Dependency Injection)
// ─────────────────────────────────────────────

/// Provides the [ApiService] singleton.
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

/// Provides the [LocationService] singleton.
final locationServiceProvider = Provider<LocationService>((ref) => LocationService());

// ─────────────────────────────────────────────
// App-Level State Providers
// ─────────────────────────────────────────────

/// Controls the current locale: `true` = English, `false` = Urdu.
final localeProvider = StateProvider<bool>((ref) => true);

/// Controls the online/offline status indicator.
final connectivityProvider = StateProvider<bool>((ref) => true);

// ─────────────────────────────────────────────
// Job Data Providers
// ─────────────────────────────────────────────

/// Fetches pending jobs from the mock API.
/// Auto-disposes when no longer listened to.
///
/// // TODO: ANTIGRAVITY HOOK — This will automatically use the real API
/// once ApiService methods are replaced with actual HTTP calls.
final pendingJobsProvider = FutureProvider.autoDispose<List<JobModel>>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  return apiService.fetchPendingJobs();
});

/// Fetches customer reviews.
final reviewsProvider = FutureProvider.autoDispose<List<ReviewModel>>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  return apiService.fetchReviews();
});

// ─────────────────────────────────────────────
// Active Job State Machine
// ─────────────────────────────────────────────

/// Manages the lifecycle of the currently active job.
///
/// State transitions: pending → accepted → arrived → completed
/// Each transition fires an API call and (for "arrived") a GPS ping.
class ActiveJobNotifier extends StateNotifier<ActiveJobState> {
  final ApiService _apiService;
  final LocationService _locationService;
  final Ref _ref;

  ActiveJobNotifier(this._apiService, this._locationService, this._ref)
      : super(const ActiveJobState());

  /// Sets the current job to work on.
  void setJob(JobModel job) {
    state = ActiveJobState(job: job, isLoading: false, error: null);
  }

  /// Transition: pending → accepted
  Future<void> acceptJob() async {
    if (state.job == null) return;
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _apiService.updateJobState(state.job!.id, 'accepted');
      state = state.copyWith(
        job: state.job!.copyWith(status: JobStatus.accepted),
        isLoading: false,
      );
      _ref.invalidate(pendingJobsProvider);
      _ref.invalidate(reviewsProvider);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Transition: accepted → arrived (fires GPS ping)
  Future<void> markArrived() async {
    if (state.job == null) return;
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Fire GPS ping first
      await _locationService.sendLocationPing(state.job!.id);
      // Then update job state
      await _apiService.updateJobState(state.job!.id, 'arrived');
      state = state.copyWith(
        job: state.job!.copyWith(status: JobStatus.arrived),
        isLoading: false,
      );
      _ref.invalidate(pendingJobsProvider);
      _ref.invalidate(reviewsProvider);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Transition: arrived → completed
  Future<void> completeJob() async {
    if (state.job == null) return;
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _apiService.updateJobState(state.job!.id, 'completed');
      state = state.copyWith(
        job: state.job!.copyWith(status: JobStatus.completed),
        isLoading: false,
      );
      _ref.invalidate(pendingJobsProvider);
      _ref.invalidate(reviewsProvider);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Resets the active job (go back to dashboard).
  void clearJob() {
    state = const ActiveJobState();
    _ref.invalidate(pendingJobsProvider);
    _ref.invalidate(reviewsProvider);
  }
}

/// Immutable state container for the active job.
class ActiveJobState {
  final JobModel? job;
  final bool isLoading;
  final String? error;

  const ActiveJobState({
    this.job,
    this.isLoading = false,
    this.error,
  });

  ActiveJobState copyWith({
    JobModel? job,
    bool? isLoading,
    String? error,
  }) {
    return ActiveJobState(
      job: job ?? this.job,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// The active job provider using [StateNotifierProvider].
final activeJobProvider =
    StateNotifierProvider<ActiveJobNotifier, ActiveJobState>((ref) {
  final apiService = ref.read(apiServiceProvider);
  final locationService = ref.read(locationServiceProvider);
  return ActiveJobNotifier(apiService, locationService, ref);
});
