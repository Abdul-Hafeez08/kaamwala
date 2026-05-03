import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/worker_provider.dart';
import '../../controllers/worker_controller.dart';

class WorkerActiveJobsScreen extends ConsumerWidget {
  const WorkerActiveJobsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(workerJobsStreamProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Active Jobs', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: jobsAsync.when(
        data: (jobs) {
          final activeJobs = jobs.where((j) => j.status == 'accepted' || j.status == 'working').toList();

          if (activeJobs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.work_rounded, size: 60, color: Colors.grey.withOpacity(0.5)),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'No Active Jobs',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Jobs you accept will show up here.\nStart earning by taking requests!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: isDark ? Colors.white38 : Colors.black38),
                  ),
                ],
              ),
            );
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: activeJobs.length,
                itemBuilder: (context, index) {
                  final job = activeJobs[index];
                  final isWorking = job.status == 'working';
    
                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                      border: Border.all(
                        color: isWorking 
                            ? const Color(0xFFFF9800).withOpacity(0.3) 
                            : (isDark ? Colors.white10 : Colors.black.withOpacity(0.03)),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF9800).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: const Icon(Icons.person_rounded, color: Color(0xFFFF9800)),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      job.userName.isNotEmpty ? job.userName : 'Customer',
                                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      DateFormat('EEEE, MMM dd').format(job.scheduledDate),
                                      style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isWorking ? Colors.green.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  isWorking ? 'WORKING' : 'ACCEPTED',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 11,
                                    color: isWorking ? Colors.green : Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Divider(height: 1),
                          ),
                          _InfoRow(Icons.location_on_rounded, job.address.isNotEmpty ? job.address : job.location),
                          if (job.userPhone.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            _InfoRow(Icons.phone_iphone_rounded, job.userPhone),
                          ],
                          if (job.startedAt != null) ...[
                            const SizedBox(height: 12),
                            _InfoRow(Icons.play_circle_outline_rounded, 'Started at: ${DateFormat('hh:mm a').format(job.startedAt!)}'),
                          ],
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                if (job.status == 'accepted') {
                                  WorkerController().updateJobStatus(job.jobId, 'working');
                                } else {
                                  _showCompletionDialog(context, job.jobId);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isWorking ? Colors.green : const Color(0xFFFF9800),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 0,
                              ),
                              child: Text(
                                isWorking ? 'Mark as Completed' : 'Start Working Now',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: SelectableText('Error: $err')),
      ),
    );
  }

  void _showCompletionDialog(BuildContext context, String jobId) {
    final priceController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Job Completion', style: TextStyle(fontWeight: FontWeight.w900)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Please enter the final amount charged for this service.',
                style: TextStyle(fontSize: 14, color: isDark ? Colors.white60 : Colors.black54),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: 'Amount (Rs.)',
                  prefixIcon: const Icon(Icons.payments_rounded, color: Color(0xFFFF9800)),
                  filled: true,
                  fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () {
                final price = double.tryParse(priceController.text.trim()) ?? 0.0;
                WorkerController().updateJobStatus(jobId, 'completed', price: price);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9800),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Confirm & Finish', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFFFF9800)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black87,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
