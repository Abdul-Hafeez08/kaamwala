import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/worker_provider.dart';
import '../auth/login_screen.dart';
import '../worker/worker_dashboard_screen.dart';
import '../worker/worker_pending_screen.dart';
import '../worker/worker_profile_setup_screen.dart';
import '../admin/admin_main_screen.dart';
import '../user/user_main_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      _checkAuthAndNavigate();
    });
  }

  Future<void> _checkAuthAndNavigate() async {
    if (!mounted) return;

    final authState = ref.read(authStateProvider);

    authState.when(
      data: (user) async {
        if (user == null) {
          _navigateTo(const LoginScreen());
        } else {
          final role = await ref.read(userRoleProvider.future);

          if (!mounted) return;

          if (role == 'worker') {
            final workerProfile = await ref.read(workerProfileProvider.future);

            if (!mounted) return;

            if (workerProfile == null || workerProfile.serviceType.isEmpty) {
              _navigateTo(const WorkerProfileSetupScreen());
            } else if (workerProfile.approvalStatus == 'approved') {
              _navigateTo(const WorkerDashboardScreen());
            } else {
              _navigateTo(const WorkerPendingScreen());
            }
          } else if (role == 'user') {
            _navigateTo(const UserMainScreen());
          } else if (role == 'admin') {
            _navigateTo(const AdminMainScreen());
          } else {
            _navigateTo(const LoginScreen());
          }
        }
      },
      loading: () {
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) _checkAuthAndNavigate();
        });
      },
      error: (_, _) {
        _navigateTo(const LoginScreen());
      },
    );
  }

  void _navigateTo(Widget screen) {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.home_repair_service,
              size: 80,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 24),

            Text(
              'Kaamwala',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              'Home Services at Your Doorstep',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 48),

            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

