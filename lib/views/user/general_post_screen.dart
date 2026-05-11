import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/service_model.dart';
import '../../controllers/booking_controller.dart';
import '../../providers/user_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import 'package:kaamwala/views/widgets/custom_loading_indicator.dart';

class GeneralPostScreen extends ConsumerStatefulWidget {
  const GeneralPostScreen({super.key});

  @override
  ConsumerState<GeneralPostScreen> createState() => _GeneralPostScreenState();
}

class _GeneralPostScreenState extends ConsumerState<GeneralPostScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final BookingController _bookingController = BookingController();

  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);
  bool _isLoading = false;

  @override
  void dispose() {
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _postToMarketplace() async {
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final userProfile = ref.read(userProfileProvider).valueOrNull;
    if (userProfile == null) return;

    setState(() => _isLoading = true);

    try {
      final timeString = '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

      await _bookingController.createBooking(
        userId: userProfile.userId,
        workerId: '', // Empty for general requests
        serviceType: _selectedCategory!,
        description: _descriptionController.text.trim(),
        address: _addressController.text.trim(),
        location: userProfile.location,
        userName: userProfile.name,
        userPhone: userProfile.phone,
        workerName: '',
        workerImage: '',
        scheduledDate: _selectedDate,
        scheduledTime: timeString,
        isGeneralRequest: true,
      );

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.rocket_launch_rounded, color: Colors.orange, size: 28),
              SizedBox(width: 8),
              Text('Posted Successfully'),
            ],
          ),
          content: const Text(
            'Your request has been posted to the marketplace. Available workers in this category will see it and accept it soon.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final servicesAsync = ref.watch(availableServicesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post to Marketplace'),
      ),
      body: servicesAsync.when(
        data: (services) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Service Category',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF8F8F8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      isExpanded: true,
                      hint: const Text('Choose a category'),
                      items: services.map((s) => DropdownMenuItem(value: s.name, child: Text(s.name))).toList(),
                      onChanged: (val) => setState(() => _selectedCategory = val),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Preferred Schedule',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _SchedulePicker(
                        onTap: _pickDate,
                        icon: Icons.calendar_today_rounded,
                        label: 'Date',
                        value: DateFormat('MMM dd, yyyy').format(_selectedDate),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SchedulePicker(
                        onTap: _pickTime,
                        icon: Icons.access_time_rounded,
                        label: 'Time',
                        value: _selectedTime.format(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const Text(
                  'Job Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _addressController,
                  label: 'Service Location / Address',
                  hintText: 'Where do you need the service?',
                  prefixIcon: Icons.location_on_rounded,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter an address';
                    return null;
                  },
                ),
                CustomTextField(
                  controller: _descriptionController,
                  label: 'Describe what you need',
                  hintText: 'e.g. I need a plumber to fix a leaking tap in the kitchen.',
                  prefixIcon: Icons.description_rounded,
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please provide a description';
                    return null;
                  },
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
        loading: () => const Center(child: CustomLoadingIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? Colors.black : Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
        ),
        child: SafeArea(
          child: CustomButton(
            text: 'Post Request',
            onPressed: _postToMarketplace,
            isLoading: _isLoading,
          ),
        ),
      ),
    );
  }
}

class _SchedulePicker extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String label;
  final String value;

  const _SchedulePicker({required this.onTap, required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: const Color(0xFFFF9800)),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
