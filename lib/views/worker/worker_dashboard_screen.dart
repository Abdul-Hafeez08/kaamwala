import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/worker_provider.dart';
import 'worker_job_requests_screen.dart';
import 'worker_active_jobs_screen.dart';
import 'worker_completed_jobs_screen.dart';
import 'worker_earnings_screen.dart';
import 'worker_profile_screen.dart';
import 'find_jobs_screen.dart';
import '../chat/chat_list_screen.dart';
import '../../providers/chat_provider.dart';
import '../widgets/curved_bottom_nav.dart';
import 'package:kaamwala/views/widgets/custom_loading_indicator.dart';

class WorkerDashboardScreen extends ConsumerStatefulWidget {
  const WorkerDashboardScreen({super.key});

  @override
  ConsumerState<WorkerDashboardScreen> createState() => _WorkerDashboardScreenState();
}

class _WorkerDashboardScreenState extends ConsumerState<WorkerDashboardScreen> {
  int _currentTabIndex = 0;

  final List<Widget> _screens = const [
    _DashboardHome(),
    FindJobsScreen(),
    WorkerJobRequestsScreen(),
    WorkerActiveJobsScreen(),
    WorkerEarningsScreen(),
    WorkerProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentTabIndex],
      bottomNavigationBar: CurvedBottomNavBar(
        currentIndex: _currentTabIndex,
        onTap: (index) => setState(() => _currentTabIndex = index),
        items: const [
          CurvedNavItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard_rounded, label: 'Home'),
          CurvedNavItem(icon: Icons.search_rounded, activeIcon: Icons.manage_search_rounded, label: 'Find Jobs'),
          CurvedNavItem(icon: Icons.assignment_outlined, activeIcon: Icons.assignment_rounded, label: 'Requests'),
          CurvedNavItem(icon: Icons.work_outline_rounded, activeIcon: Icons.work_rounded, label: 'Active'),
          CurvedNavItem(icon: Icons.account_balance_wallet_outlined, activeIcon: Icons.account_balance_wallet_rounded, label: 'Earnings'),
          CurvedNavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profile'),
        ],
      ),
    );
  }
}

class _DashboardHome extends ConsumerWidget {
  const _DashboardHome();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workerStream = ref.watch(workerProfileStreamProvider);
    final jobsAsync = ref.watch(workerJobsStreamProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return workerStream.when(
      data: (worker) {
        final jobs = jobsAsync.valueOrNull ?? [];
        final pendingJobs = jobs.where((j) => j.status == 'pending').length;
        final activeJobs = jobs.where((j) => j.status == 'accepted' || j.status == 'working').length;
        final completedJobs = jobs.where((j) => j.status == 'completed' || j.status == 'reviewed').length;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Kaamwala', style: TextStyle(fontWeight: FontWeight.w900)),
            actions: [
              Consumer(
                builder: (context, ref, child) {
                  final unreadCount = ref.watch(totalUnreadCountWorkerProvider);
                  return Badge(
                    label: Text(unreadCount.toString()),
                    isLabelVisible: unreadCount > 0,
                    offset: const Offset(-2, 2),
                    child: IconButton(
                      icon: const Icon(Icons.chat_bubble_outline_rounded),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ChatListScreen(isWorker: true),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF9800).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back,',
                            style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.8)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            worker?.name ?? 'Provider',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              worker?.serviceType ?? 'Expert Service',
                              style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
    
                    const Text(
                      'Job Statistics',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
    
                    Column(
                      children: [
                        _buildStatCard(context, 'Pending Jobs', pendingJobs.toString(), Icons.inbox_rounded, Colors.blue),
                        const SizedBox(height: 12),
                        _buildStatCard(context, 'Active Jobs', activeJobs.toString(), Icons.play_circle_filled_rounded, Colors.orange),
                        const SizedBox(height: 12),
                        _buildStatCard(context, 'Completed Services', completedJobs.toString(), Icons.check_circle_rounded, Colors.green),
                        const SizedBox(height: 12),
                        _buildStatCard(context, 'Worker Rating', worker?.rating.toStringAsFixed(1) ?? '0.0', Icons.star_rounded, Colors.amber),
                      ],
                    ),
                    const SizedBox(height: 32),
    
                    const Text(
                      'Quick Navigation',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
    
                    _QuickLinkTile(
                      icon: Icons.history_rounded,
                      title: 'Job History',
                      subtitle: 'View all your past services',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (_) => const WorkerCompletedJobsScreen(),
                        ));
                      },
                    ),
                    _QuickLinkTile(
                      icon: Icons.account_balance_wallet_rounded,
                      title: 'Payments',
                      subtitle: 'Check your earnings and history',
                      onTap: () {
                        // Navigate to earnings
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CustomLoadingIndicator())),
      error: (error, _) => Scaffold(body: Center(child: SelectableText('Error: $error'))),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.03),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded, size: 14, color: isDark ? Colors.white10 : Colors.black12),
        ],
      ),
    );
  }
}

class _QuickLinkTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickLinkTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.03),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFFF9800).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFFFF9800)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}


