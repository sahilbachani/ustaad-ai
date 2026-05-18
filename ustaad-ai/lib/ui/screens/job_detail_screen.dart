import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ustaad_ai/core/theme/colors.dart';
import 'package:ustaad_ai/core/localization/english_strings.dart';
import 'package:ustaad_ai/core/localization/urdu_strings.dart';
import 'package:ustaad_ai/models/job_model.dart';
import 'package:ustaad_ai/providers/job_state_provider.dart';
import 'package:ustaad_ai/ui/widgets/custom_button.dart';
import 'package:ustaad_ai/ui/widgets/status_badge.dart';
import 'package:ustaad_ai/ui/screens/camera_proof_screen.dart';

/// Job execution screen — manages the active job state machine.
class JobDetailScreen extends ConsumerWidget {
  const JobDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEnglish = ref.watch(localeProvider);
    final jobState = ref.watch(activeJobProvider);
    final job = jobState.job;

    if (job == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(backgroundColor: AppColors.surface),
        body: const Center(
          child: Text('No job selected',
              style: TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(activeJobProvider.notifier).clearJob();
            Navigator.pop(context);
          },
        ),
        title: Text(
          isEnglish ? EnglishStrings.jobDetails : UrduStrings.jobDetails,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: StatusBadge(status: job.status, isEnglish: isEnglish),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ServiceHeader(job: job, isEnglish: isEnglish),
                  const SizedBox(height: 24),
                  _InfoRow(
                    icon: Icons.location_on,
                    label: isEnglish ? EnglishStrings.location : UrduStrings.location,
                    value: isEnglish ? job.location : job.locationUrdu,
                  ),
                  const SizedBox(height: 16),
                  _InfoRow(
                    icon: Icons.person,
                    label: isEnglish ? EnglishStrings.customer : UrduStrings.customer,
                    value: job.customerName,
                  ),
                  const SizedBox(height: 16),
                  _InfoRow(
                    icon: Icons.phone,
                    label: isEnglish ? EnglishStrings.phone : UrduStrings.phone,
                    value: job.customerPhone,
                  ),
                  const SizedBox(height: 24),
                  _PayoutCard(job: job, isEnglish: isEnglish),
                  _InteractiveMapTracker(job: job, isEnglish: isEnglish),
                  _NearbyMaterialsSearch(job: job, isEnglish: isEnglish),
                  if (job.status == JobStatus.completed) ...[
                    const SizedBox(height: 32),
                    _CompletedBanner(isEnglish: isEnglish),
                  ],
                ],
              ),
            ),
          ),
          if (job.status != JobStatus.completed)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: _ActionButton(
                job: job,
                jobState: jobState,
                isEnglish: isEnglish,
              ),
            ),
        ],
      ),
    );
  }
}

class _ServiceHeader extends StatelessWidget {
  final JobModel job;
  final bool isEnglish;
  const _ServiceHeader({required this.job, required this.isEnglish});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(_icon, color: AppColors.primary, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEnglish ? job.serviceType : job.serviceTypeUrdu,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  isEnglish ? job.serviceTypeUrdu : job.serviceType,
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData get _icon {
    switch (job.serviceType.toLowerCase()) {
      case 'ac repair': return Icons.ac_unit;
      case 'electrical wiring': return Icons.electrical_services;
      case 'plumbing': return Icons.plumbing;
      case 'painting': return Icons.format_paint;
      default: return Icons.build;
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: AppColors.textSecondary, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            ],
          ),
        ),
      ],
    );
  }
}

class _PayoutCard extends StatelessWidget {
  final JobModel job;
  final bool isEnglish;
  const _PayoutCard({required this.job, required this.isEnglish});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withValues(alpha: 0.12), AppColors.primary.withValues(alpha: 0.04)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(isEnglish ? EnglishStrings.estimatedPayout : UrduStrings.estimatedPayout,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Text('Rs ${job.estimatedPayout.toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: AppColors.primary, letterSpacing: -1)),
        ],
      ),
    );
  }
}

class _CompletedBanner extends StatelessWidget {
  final bool isEnglish;
  const _CompletedBanner({required this.isEnglish});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.statusCompleted.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.statusCompleted.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle, color: AppColors.statusCompleted, size: 48),
          const SizedBox(height: 12),
          Text(isEnglish ? EnglishStrings.jobCompleted : UrduStrings.jobCompleted,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.statusCompleted)),
        ],
      ),
    );
  }
}

/// The massive state-machine action button.
class _ActionButton extends ConsumerWidget {
  final JobModel job;
  final ActiveJobState jobState;
  final bool isEnglish;
  const _ActionButton({required this.job, required this.jobState, required this.isEnglish});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (job.status) {
      case JobStatus.pending:
        return CustomButton(
          label: isEnglish ? EnglishStrings.acceptJob : UrduStrings.acceptJob,
          subLabel: isEnglish ? 'کام قبول کریں' : 'Accept Job',
          icon: Icons.check_circle_outline,
          backgroundColor: AppColors.primary,
          textColor: AppColors.textOnPrimary,
          isLoading: jobState.isLoading,
          minHeight: 80,
          onPressed: () => ref.read(activeJobProvider.notifier).acceptJob(),
        );
      case JobStatus.accepted:
        return CustomButton(
          label: isEnglish ? EnglishStrings.iHaveArrived : UrduStrings.iHaveArrived,
          subLabel: isEnglish ? 'پہنچ گیا' : 'I Have Arrived',
          icon: Icons.location_on,
          backgroundColor: AppColors.statusPending,
          textColor: AppColors.textOnPrimary,
          isLoading: jobState.isLoading,
          minHeight: 80,
          onPressed: () => ref.read(activeJobProvider.notifier).markArrived(),
        );
      case JobStatus.arrived:
        return CustomButton(
          label: isEnglish ? EnglishStrings.uploadProofComplete : UrduStrings.uploadProofComplete,
          subLabel: isEnglish ? 'ثبوت اپ لوڈ کریں' : 'Upload Proof & Complete',
          icon: Icons.camera_alt,
          backgroundColor: AppColors.statusArrived,
          textColor: Colors.white,
          isLoading: jobState.isLoading,
          minHeight: 80,
          onPressed: () {
            Navigator.push(context,
              MaterialPageRoute(builder: (_) => CameraProofScreen(jobId: job.id)));
          },
        );
      case JobStatus.completed:
        return const SizedBox.shrink();
    }
  }
}

class _InteractiveMapTracker extends StatelessWidget {
  final JobModel job;
  final bool isEnglish;

  const _InteractiveMapTracker({required this.job, required this.isEnglish});

  @override
  Widget build(BuildContext context) {
    String statusText = '';
    Color statusColor = Colors.grey;

    if (job.status == JobStatus.pending) {
      statusText = isEnglish ? 'Pending Acceptance' : 'قبولیت کے انتظار میں';
      statusColor = AppColors.primary;
    } else if (job.status == JobStatus.accepted) {
      statusText = isEnglish ? 'In Transit (Navigation Active)' : 'راستے میں (نقشہ فعال ہے)';
      statusColor = AppColors.statusPending;
    } else if (job.status == JobStatus.arrived) {
      statusText = isEnglish ? 'Arrived at Customer Location' : 'کسٹمر کی جگہ پر پہنچ گئے';
      statusColor = AppColors.statusArrived;
    } else if (job.status == JobStatus.completed) {
      statusText = isEnglish ? 'Job Completed' : 'کام مکمل ہو گیا';
      statusColor = AppColors.success;
    }

    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isEnglish ? 'Live Location Tracker' : 'لائیو لوکیشن ٹریکر',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor, width: 1),
                ),
                child: Text(
                  statusText.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Clean custom mock visual map using containers and custom painters
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2C),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // Vector Grid/Street Simulator Pattern
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.15,
                      child: GridPaper(
                        color: Colors.cyanAccent,
                        interval: 40.0,
                        subdivisions: 1,
                        child: Container(),
                      ),
                    ),
                  ),
                  // Mock Street Paths
                  Positioned(
                    top: 60, left: 0, right: 0,
                    child: Container(height: 16, color: Colors.white.withOpacity(0.08)),
                  ),
                  Positioned(
                    top: 120, left: 0, right: 0,
                    child: Container(height: 16, color: Colors.white.withOpacity(0.08)),
                  ),
                  Positioned(
                    left: 80, top: 0, bottom: 0,
                    child: Container(width: 16, color: Colors.white.withOpacity(0.08)),
                  ),
                  Positioned(
                    left: 240, top: 0, bottom: 0,
                    child: Container(width: 16, color: Colors.white.withOpacity(0.08)),
                  ),
                  // Draw Simulated Routing Line
                  Positioned(
                    left: 88, top: 68, width: 160, height: 60,
                    child: CustomPaint(
                      painter: _RouteLinePainter(),
                    ),
                  ),
                  // Customer Pin
                  const Positioned(
                    right: 70,
                    top: 50,
                    child: Column(
                      children: [
                        Icon(Icons.location_on, color: Colors.redAccent, size: 32),
                        Text(
                          'Clifton',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Provider Pulsing GPS Pin (Only if accepted or arrived)
                  if (job.status == JobStatus.accepted || job.status == JobStatus.arrived)
                    Positioned(
                      left: job.status == JobStatus.arrived ? 240 : 80,
                      top: job.status == JobStatus.arrived ? 50 : 110,
                      child: const _PulsingGpsDot(),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Route Details
          Row(
            children: [
              const Icon(Icons.navigation, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isEnglish
                      ? 'Route: Clifton Block 5 → Zamzama Commercial (1.2 km away)'
                      : 'راستہ: کلفٹن بلاک 5 ← زمزمہ کمرشل (1.2 کلومیٹر فاصلہ)',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RouteLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.cyanAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PulsingGpsDot extends StatefulWidget {
  const _PulsingGpsDot();

  @override
  State<_PulsingGpsDot> createState() => _PulsingGpsDotState();
}

class _PulsingGpsDotState extends State<_PulsingGpsDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 24 * _controller.value,
              height: 24 * _controller.value,
              decoration: BoxDecoration(
                color: Colors.cyanAccent.withOpacity(1 - _controller.value),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Colors.cyanAccent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 4),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _NearbyMaterialsSearch extends StatefulWidget {
  final JobModel job;
  final bool isEnglish;

  const _NearbyMaterialsSearch({required this.job, required this.isEnglish});

  @override
  State<_NearbyMaterialsSearch> createState() => _NearbyMaterialsSearchState();
}

class _NearbyMaterialsSearchState extends State<_NearbyMaterialsSearch> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _searching = false;

  void _performSearch() async {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return;

    setState(() {
      _searching = true;
      _searchResults = [];
    });

    // Simulate search query analysis and Map tool lookup
    await Future.delayed(const Duration(milliseconds: 800));

    // Dynamic results based on job type and query
    final isPlumbing = widget.job.serviceType.toLowerCase().contains('plumb');
    
    if (query.contains('pipe') || query.contains('tap') || query.contains('sanitary') || isPlumbing) {
      _searchResults = [
        {
          'name': 'Zamzama Sanitary & Hardware Store',
          'distance': '0.4 km',
          'items': 'PPR Pipes, Elbows, Teflon Tape',
          'price': 'Rs. 150 - Rs. 850',
          'rating': '4.8',
        },
        {
          'name': 'Clifton Builders Hub',
          'distance': '1.2 km',
          'items': 'High-pressure valves, Pipe glue',
          'price': 'Rs. 250 - Rs. 1,200',
          'rating': '4.5',
        },
      ];
    } else {
      _searchResults = [
        {
          'name': 'Clifton Electrical & Gas Center',
          'distance': '0.6 km',
          'items': 'Copper tubes, Gas Refill cylinders, Gas tape',
          'price': 'Rs. 350 - Rs. 3,800',
          'rating': '4.9',
        },
        {
          'name': 'Defence Hardware Mart',
          'distance': '1.5 km',
          'items': 'AC capacitors, Copper wiring, Screws',
          'price': 'Rs. 100 - Rs. 1,500',
          'rating': '4.3',
        },
      ];
    }

    setState(() {
      _searching = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.isEnglish ? 'Search Nearby Hardware & Tools' : 'قریبی ہارڈ ویئر اور ٹولز تلاش کریں',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: widget.isEnglish ? 'Enter materials (e.g. pipe, tape, wire)' : 'مواد درج کریں (جیسے پائپ، ٹیپ)',
                    hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: _performSearch,
                ),
              ),
            ],
          ),
          if (_searching)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            )
          else if (_searchResults.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(color: AppColors.divider),
            const SizedBox(height: 8),
            Text(
              widget.isEnglish ? 'Matched Nearby Stores:' : 'قریبی اسٹورز:',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            ..._searchResults.map((store) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                store['name'],
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '⭐ ${store['rating']}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.amber),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.isEnglish ? "Available items:" : "دستیاب اشیاء:"} ${store['items']}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              store['price'],
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                            ),
                            Text(
                              '📍 ${store['distance']}',
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )),
          ],
        ],
      ),
    );
  }
}
