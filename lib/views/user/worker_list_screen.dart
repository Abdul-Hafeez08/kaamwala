import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/user_provider.dart';
import '../../models/user_model.dart';
import 'worker_detail_screen.dart';
import '../../services/firestore_service.dart';
import '../chat/chat_room_screen.dart';

class WorkerListScreen extends ConsumerWidget {
  final String serviceType;
  final IconData serviceIcon;

  const WorkerListScreen({
    super.key,
    required this.serviceType,
    required this.serviceIcon,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workersAsync = ref.watch(workersByServiceProvider(serviceType));

    return Scaffold(
      appBar: AppBar(
        title: Text(serviceType),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(workersByServiceProvider(serviceType));
        },
        child: workersAsync.when(
          data: (workers) {
            final available = workers.where((w) => w.availability).toList();

            if (available.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      serviceIcon,
                      size: 64,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No $serviceType available right now',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please check back later',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: available.length,
              itemBuilder: (context, index) {
                final worker = available[index];
                return _WorkerCard(
                  worker: worker,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WorkerDetailScreen(worker: worker),
                      ),
                    );
                  },
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
            child: Text('Error: $err',
                style: const TextStyle(color: Colors.red)),
          ),
        ),
      ),
    );
  }
}

class _WorkerCard extends ConsumerWidget {
  final WorkerModel worker;
  final VoidCallback onTap;

  const _WorkerCard({required this.worker, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: worker.profileImage.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(worker.profileImage),
                              fit: BoxFit.cover,
                            )
                          : null,
                      color: const Color(0xFFFF9800).withOpacity(0.1),
                    ),
                    child: worker.profileImage.isEmpty
                        ? const Icon(Icons.person, size: 35, color: Color(0xFFFF9800))
                        : null,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: worker.availability ? Colors.green : Colors.grey,
                        shape: BoxShape.circle,
                        border: Border.all(color: isDark ? const Color(0xFF1E1E1E) : Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            worker.name,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF9800).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFF9800)),
                              const SizedBox(width: 2),
                              Text(
                                worker.rating > 0 ? worker.rating.toStringAsFixed(1) : 'New',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFF9800),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      worker.skills.isEmpty ? 'General ${worker.serviceType} services' : worker.skills,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white70 : Colors.black87,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.work_history_rounded, size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            worker.experience.isEmpty ? 'New Worker' : worker.experience,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded, size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            worker.location.isEmpty ? 'Location N/A' : worker.location,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chat_bubble_rounded, color: Color(0xFFFF9800)),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9800).withOpacity(0.1),
                      padding: const EdgeInsets.all(8),
                    ),
                    onPressed: () async {
                      final userProfile = ref.read(userProfileProvider).valueOrNull;
                      if (userProfile == null) return;
                      
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (ctx) => const Center(child: CircularProgressIndicator()),
                      );

                      try {
                        final chat = await FirestoreService().createOrGetChat(
                          userId: userProfile.userId,
                          workerId: worker.workerId,
                          userName: userProfile.name,
                          userImage: userProfile.profileImage ?? '',
                          workerName: worker.name,
                          workerImage: worker.profileImage,
                        );
                        
                        if (context.mounted) {
                          Navigator.pop(context); // close loader
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatRoomScreen(
                                chatId: chat.chatId,
                                chatTitle: worker.name,
                                chatImage: worker.profileImage,
                                isWorker: false,
                                currentUserId: userProfile.userId,
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) Navigator.pop(context); // close loader
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
