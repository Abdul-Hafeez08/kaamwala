import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/job_model.dart';
import '../../providers/user_provider.dart';
import '../../controllers/booking_controller.dart';
import 'review_screen.dart';

class UserBookingsScreen extends ConsumerWidget {
  const UserBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(userBookingsStreamProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Bookings'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Active'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: bookingsAsync.when(
          data: (bookings) {
            final active = bookings
                .where((j) =>
                    j.status == 'pending' ||
                    j.status == 'accepted' ||
                    j.status == 'working')
                .toList();
            final completed = bookings
                .where((j) =>
                    j.status == 'completed' ||
                    j.status == 'reviewed' ||
                    j.status == 'cancelled')
                .toList();

            return TabBarView(
              children: [
                _BookingList(bookings: active, isActive: true),
                _BookingList(bookings: completed, isActive: false),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
            child:
                SelectableText('Error: $err', style: const TextStyle(color: Colors.red)),
          ),
        ),
      ),
    );
  }
}

class _BookingList extends StatelessWidget {
  final List<JobModel> bookings;
  final bool isActive;

  const _BookingList({required this.bookings, required this.isActive});

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? Icons.calendar_today : Icons.history,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              isActive ? 'No active bookings' : 'No completed bookings',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        return _BookingCard(booking: bookings[index], isActive: isActive);
      },
    );
  }
}

class _BookingCard extends StatelessWidget {
  final JobModel booking;
  final bool isActive;

  const _BookingCard({required this.booking, required this.isActive});

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return const Color(0xFFFF9800);
      case 'accepted':
        return Colors.blue;
      case 'working':
        return Colors.indigo;
      case 'completed':
        return Colors.green;
      case 'reviewed':
        return Colors.teal;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'working':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'reviewed':
        return 'Reviewed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(booking.status);
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
                    borderRadius: BorderRadius.circular(14),
                    image: booking.workerImage.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(booking.workerImage),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: const Color(0xFFFF9800).withOpacity(0.1),
                  ),
                  child: booking.workerImage.isEmpty
                      ? const Icon(Icons.person, size: 25, color: Color(0xFFFF9800))
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.workerName.isEmpty ? 'Worker' : booking.workerName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        booking.serviceType,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFFFF9800),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _statusLabel(booking.status),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1),
            ),
            Row(
              children: [
                Expanded(
                  child: _BookingInfoItem(
                    icon: Icons.calendar_today_rounded,
                    text: DateFormat('MMM dd, yyyy').format(booking.scheduledDate),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _BookingInfoItem(
                    icon: Icons.access_time_rounded,
                    text: booking.scheduledTime.isEmpty ? 'N/A' : booking.scheduledTime,
                  ),
                ),
              ],
            ),
            _BookingInfoItem(
              icon: Icons.location_on_rounded,
              text: booking.address.isEmpty ? 'N/A' : booking.address,
            ),
            if (booking.startedAt != null || booking.completedAt != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (booking.startedAt != null)
                    Expanded(
                      child: _BookingInfoItem(
                        icon: Icons.play_circle_outline_rounded,
                        text: 'Started: ${DateFormat('hh:mm a').format(booking.startedAt!)}',
                      ),
                    ),
                  if (booking.completedAt != null)
                    Expanded(
                      child: _BookingInfoItem(
                        icon: Icons.check_circle_outline_rounded,
                        text: 'Ended: ${DateFormat('hh:mm a').format(booking.completedAt!)}',
                      ),
                    ),
                ],
              ),
            ],
            if (booking.price > 0) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Amount:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    'Rs. ${booking.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
            if (isActive && booking.status == 'pending') ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _cancelBooking(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Cancel Booking'),
                ),
              ),
            ],
            if (!isActive && booking.status == 'completed') ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReviewScreen(booking: booking),
                      ),
                    );
                  },
                  icon: const Icon(Icons.star_rounded, size: 18),
                  label: const Text('Leave a Review'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9800),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
            if (booking.status == 'reviewed' && booking.userRating > 0) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'Your rating: ',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                  const SizedBox(width: 4),
                  ...List.generate(5, (i) {
                    return Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: i < booking.userRating.round() ? const Color(0xFFFF9800) : Colors.grey.withOpacity(0.3),
                    );
                  }),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _cancelBooking(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Cancel Booking?'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('No', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final controller = BookingController();
              await controller.cancelBooking(booking.jobId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}

class _BookingInfoItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _BookingInfoItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Icon(icon, size: 14, color: isDark ? Colors.white38 : Colors.black38),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white70 : Colors.black87,
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
