import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../models/job_model.dart';
import '../models/service_model.dart';
import 'auth_provider.dart';

final allWorkersProvider = FutureProvider<List<WorkerModel>>((ref) async {
  final firestoreService = ref.read(firestoreServiceProvider);
  return await firestoreService.getAllWorkers();
});

final allUsersProvider = FutureProvider<List<UserModel>>((ref) async {
  final firestoreService = ref.read(firestoreServiceProvider);
  return await firestoreService.getAllUsers();
});

final servicesProvider = FutureProvider<List<ServiceCategory>>((ref) async {
  final firestoreService = ref.read(firestoreServiceProvider);
  return await firestoreService.getServices();
});

final workersByStatusProvider = FutureProvider.family<List<WorkerModel>, String>((ref, status) async {
  final firestoreService = ref.read(firestoreServiceProvider);
  return await firestoreService.getWorkersByApprovalStatus(status);
});

final allJobsProvider = FutureProvider<List<JobModel>>((ref) async {
  final firestoreService = ref.read(firestoreServiceProvider);
  return await firestoreService.getAllJobs();
});

final jobsByStatusProvider = FutureProvider.family<List<JobModel>, String>((ref, status) async {
  final firestoreService = ref.read(firestoreServiceProvider);
  return await firestoreService.getJobsByStatus(status);
});

final workerEarningsProvider = FutureProvider.family<double, String>((ref, workerId) async {
  final firestoreService = ref.read(firestoreServiceProvider);
  final jobs = await firestoreService.getWorkerJobs(workerId);
  return jobs
      .where((j) => (j.status == 'completed' || j.status == 'reviewed') && j.price > 0)
      .fold(0.0, (sum, job) => sum + job.price);
});
