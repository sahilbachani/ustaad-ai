import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:ustaad_ai/core/constants/api_endpoints.dart';
import 'package:ustaad_ai/models/job_model.dart';

class ApiService {
  static const String baseUrl = 'https://retinal-gratified-spinning.ngrok-free.dev/ustaad-ai-ce5e2/us-central1';

  // In-memory list to track job status transitions locally for the demo!
  final List<JobModel> _mockJobs = [
    JobModel(
      id: 'DEMO-JOB-1',
      serviceType: 'AC Repair',
      serviceTypeUrdu: 'اے سی مرمت',
      location: 'Gulshan, Karachi',
      locationUrdu: 'گلشن، کراچی',
      estimatedPayout: 2500,
      status: JobStatus.pending,
      customerName: 'Ahmed',
      customerPhone: '+923001234567',
      createdAt: DateTime.now(),
    ),
    JobModel(
      id: 'DEMO-JOB-2',
      serviceType: 'Plumbing',
      serviceTypeUrdu: 'پلمبنگ کی خدمات',
      location: 'Clifton, Karachi',
      locationUrdu: 'کلفٹن، کراچی',
      estimatedPayout: 1800,
      status: JobStatus.pending,
      customerName: 'Hira Fatima',
      customerPhone: '+923162005132',
      createdAt: DateTime.now(),
    ),
  ];

  /// Updates the state of a job in the backend.
  Future<bool> updateJobState(String jobId, String state) async {
    // 1. Update in-memory state so dashboard and UI reflect updates instantly!
    final index = _mockJobs.indexWhere((j) => j.id == jobId);
    if (index != -1) {
      JobStatus status = JobStatus.pending;
      if (state == 'accepted') status = JobStatus.accepted;
      if (state == 'arrived') status = JobStatus.arrived;
      if (state == 'completed') status = JobStatus.completed;
      _mockJobs[index] = _mockJobs[index].copyWith(status: status);
    }

    // Map the local state name to the backend endpoint
    String endpoint = 'acceptJob'; // default
    if (state == 'arrived') endpoint = 'providerArrived';
    if (state == 'completed') endpoint = 'completeJob';

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'jobId': jobId,
          // If arrived, backend expects latitude/longitude
          if (state == 'arrived') 'latitude': 33.6938,
          if (state == 'arrived') 'longitude': 73.0652,
          // If completed, backend expects finalPrice
          if (state == 'completed') 'finalPrice': 1500,
        }),
      );

      final data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (e) {
      print('[ApiService] Error: $e');
      return false;
    }
  }

  /// Fetches pending jobs from the server.
  Future<List<JobModel>> fetchPendingJobs() async {
    await Future.delayed(const Duration(seconds: 1));
    return _mockJobs;
  }

  Future<bool> uploadCompletionProof(String jobId, dynamic image) async {
    print('[ApiService] Proof upload logic goes here');
    return true;
  }
}
