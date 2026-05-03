import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'user_home_screen.dart';
import 'user_bookings_screen.dart';
import 'user_profile_screen.dart';
import '../chat/chat_list_screen.dart';
import '../../providers/chat_provider.dart';

class UserMainScreen extends ConsumerStatefulWidget {
  const UserMainScreen({super.key});

  @override
  ConsumerState<UserMainScreen> createState() => _UserMainScreenState();
}

class _UserMainScreenState extends ConsumerState<UserMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const UserHomeScreen(),
    const UserBookingsScreen(),
    const ChatListScreen(isWorker: false),
    const UserProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unreadCount = ref.watch(totalUnreadCountUserProvider);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          height: 70,
          backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
          elevation: 0,
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
          },
          indicatorColor: const Color(0xFFFF9800).withOpacity(0.1),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home_rounded, color: Colors.grey),
              selectedIcon: Icon(Icons.home_rounded, color: Color(0xFFFF9800)),
              label: 'Home',
            ),
            const NavigationDestination(
              icon: Icon(Icons.calendar_today_rounded, color: Colors.grey),
              selectedIcon: Icon(Icons.calendar_today_rounded, color: Color(0xFFFF9800)),
              label: 'Bookings',
            ),
            NavigationDestination(
              icon: Badge(
                label: Text(unreadCount.toString()),
                isLabelVisible: unreadCount > 0,
                child: const Icon(Icons.chat_bubble_rounded, color: Colors.grey),
              ),
              selectedIcon: Badge(
                label: Text(unreadCount.toString()),
                isLabelVisible: unreadCount > 0,
                child: const Icon(Icons.chat_bubble_rounded, color: Color(0xFFFF9800)),
              ),
              label: 'Messages',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_rounded, color: Colors.grey),
              selectedIcon: Icon(Icons.person_rounded, color: Color(0xFFFF9800)),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
