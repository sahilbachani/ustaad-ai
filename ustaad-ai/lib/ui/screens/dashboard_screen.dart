import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ustaad_ai/core/theme/colors.dart';
import 'package:ustaad_ai/core/localization/english_strings.dart';
import 'package:ustaad_ai/core/localization/urdu_strings.dart';
import 'package:ustaad_ai/models/provider_model.dart';
import 'package:ustaad_ai/models/job_model.dart';
import 'package:ustaad_ai/providers/job_state_provider.dart';
import 'package:ustaad_ai/ui/widgets/job_card.dart';
import 'package:ustaad_ai/ui/screens/job_detail_screen.dart';

/// The main dashboard screen showing active jobs and earnings.
///
/// Features:
/// - Top bar with app name, online/offline indicator, EN/UR toggle
/// - Summary card with today's earnings and trust score
/// - List of incoming pending jobs
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEnglish = ref.watch(localeProvider);
    final isOnline = ref.watch(connectivityProvider);
    final pendingJobs = ref.watch(pendingJobsProvider);

    // Mock provider data
    final provider = ProviderModel.mock;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context, ref, isEnglish, isOnline),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: () async {
          // ignore: unused_result
          ref.refresh(pendingJobsProvider);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── Summary Card ──
            SliverToBoxAdapter(
              child: _buildSummaryCard(context, provider, isEnglish),
            ),

            // ── Dynamic Active & Pending Job List ──
            pendingJobs.when(
              loading: () => const SliverToBoxAdapter(
                child: _LoadingShimmer(),
              ),
              error: (err, _) => SliverToBoxAdapter(
                child: _ErrorState(
                  isEnglish: isEnglish,
                  onRetry: () => ref.refresh(pendingJobsProvider),
                ),
              ),
              data: (jobs) {
                final activeList = jobs.where((j) => j.status == JobStatus.accepted || j.status == JobStatus.arrived).toList();
                final pendingList = jobs.where((j) => j.status == JobStatus.pending).toList();

                final List<Widget> sliverChildren = [];

                // 1. ACTIVE JOBS SECTION (if any)
                if (activeList.isNotEmpty) {
                  sliverChildren.add(
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: AppColors.statusPending, // Pulsing/Active Orange color
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isEnglish ? 'Active Jobs' : 'سرگرم کام',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );

                  for (final job in activeList) {
                    sliverChildren.add(
                      JobCard(
                        job: job,
                        isEnglish: isEnglish,
                        onTap: () {
                          ref.read(activeJobProvider.notifier).setJob(job);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const JobDetailScreen(),
                            ),
                          );
                        },
                      ),
                    );
                  }
                }

                // 2. INCOMING JOBS SECTION
                sliverChildren.add(
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                    child: Text(
                      isEnglish ? EnglishStrings.incomingJobs : UrduStrings.incomingJobs,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                );

                if (pendingList.isEmpty) {
                  sliverChildren.add(_EmptyState(isEnglish: isEnglish));
                } else {
                  for (final job in pendingList) {
                    sliverChildren.add(
                      JobCard(
                        job: job,
                        isEnglish: isEnglish,
                        onTap: () {
                          ref.read(activeJobProvider.notifier).setJob(job);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const JobDetailScreen(),
                            ),
                          );
                        },
                      ),
                    );
                  }
                }

                return SliverList(
                  delegate: SliverChildListDelegate(sliverChildren),
                );
              },
            ),

            // Bottom spacing
            const SliverToBoxAdapter(
              child: SizedBox(height: 32),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    WidgetRef ref,
    bool isEnglish,
    bool isOnline,
  ) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      title: Row(
        children: [
          // App name with neon green accent
          const Text(
            'Ustaad',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const Text(
            '.ai',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          // Online/Offline indicator
          GestureDetector(
            onTap: () {
              // Toggle connectivity for demo
              ref.read(connectivityProvider.notifier).state = !isOnline;
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: (isOnline ? AppColors.online : AppColors.offline)
                    .withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isOnline ? AppColors.online : AppColors.offline,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isOnline
                        ? (isEnglish
                            ? EnglishStrings.online
                            : UrduStrings.online)
                        : (isEnglish
                            ? EnglishStrings.offline
                            : UrduStrings.offline),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isOnline ? AppColors.online : AppColors.offline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: [
        // Language toggle
        Container(
          margin: const EdgeInsets.only(right: 12),
          child: GestureDetector(
            onTap: () {
              ref.read(localeProvider.notifier).state = !isEnglish;
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Text(
                isEnglish ? 'اردو' : 'EN',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    ProviderModel provider,
    bool isEnglish,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.15),
            AppColors.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Today's Earnings
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEnglish
                      ? EnglishStrings.todayEarnings
                      : UrduStrings.todayEarnings,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Rs ${provider.todayEarnings.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Container(
            width: 1,
            height: 60,
            color: AppColors.divider,
          ),
          const SizedBox(width: 20),

          // Trust Score
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                isEnglish
                    ? EnglishStrings.trustScore
                    : UrduStrings.trustScore,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: AppColors.warning, size: 24),
                  const SizedBox(width: 4),
                  Text(
                    '${provider.trustScore}/5.0',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Shimmer loading placeholder for the job list.
class _LoadingShimmer extends StatelessWidget {
  const _LoadingShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: List.generate(
          3,
          (index) => Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Empty state when no jobs are available.
class _EmptyState extends StatelessWidget {
  final bool isEnglish;
  const _EmptyState({required this.isEnglish});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            const Icon(
              Icons.work_off_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              isEnglish
                  ? EnglishStrings.noJobsAvailable
                  : UrduStrings.noJobsAvailable,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Error state with retry button.
class _ErrorState extends StatelessWidget {
  final bool isEnglish;
  final VoidCallback onRetry;
  const _ErrorState({required this.isEnglish, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              isEnglish ? EnglishStrings.error : UrduStrings.error,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, color: AppColors.primary),
              label: Text(
                isEnglish ? EnglishStrings.retry : UrduStrings.retry,
                style: const TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
