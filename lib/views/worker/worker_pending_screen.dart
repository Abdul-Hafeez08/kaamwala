import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/auth_controller.dart';
import '../../providers/worker_provider.dart';
import '../auth/login_screen.dart';
import 'worker_dashboard_screen.dart';
import 'package:kaamwala/views/widgets/custom_loading_indicator.dart';

class WorkerPendingScreen extends ConsumerWidget {
  const WorkerPendingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workerStream = ref.watch(workerProfileStreamProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return workerStream.when(
      data: (worker) {
        if (worker != null && worker.approvalStatus == 'approved') {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const WorkerDashboardScreen()),
            );
          });
        }

        final bool isRejected = worker?.approvalStatus == 'rejected';

        return Scaffold(
          body: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: (isRejected ? Colors.red : const Color(0xFFFF9800)).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isRejected ? Icons.error_outline_rounded : Icons.pending_actions_rounded,
                    size: 80,
                    color: isRejected ? Colors.red : const Color(0xFFFF9800),
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  isRejected ? 'Profile Rejected' : 'Profile Under Review',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  isRejected
                      ? 'Your profile has been rejected by the admin. Please contact support to resolve this issue.'
                      : 'We are currently reviewing your profile to ensure quality. You\'ll receive access to your dashboard once approved.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white60 : Colors.black54,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 60),
                SizedBox(
                  width: 200,
                  child: OutlinedButton(
                    onPressed: () async {
                      await AuthController().signOut();
                      if (context.mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isRejected ? Colors.red : const Color(0xFFFF9800),
                      side: BorderSide(color: isRejected ? Colors.red : const Color(0xFFFF9800)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Logout Account', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: const CustomLoadingIndicator()),
      ),
      error: (error, _) => Scaffold(
        body: Center(child: SelectableText('Error: $error')),
      ),
    );
  }
}

