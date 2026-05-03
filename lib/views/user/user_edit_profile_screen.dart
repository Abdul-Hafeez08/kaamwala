import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../models/user_model.dart';
import '../../controllers/user_controller.dart';
import '../../services/cloudinary_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class UserEditProfileScreen extends StatefulWidget {
  final UserModel user;

  const UserEditProfileScreen({super.key, required this.user});

  @override
  State<UserEditProfileScreen> createState() => _UserEditProfileScreenState();
}

class _UserEditProfileScreenState extends State<UserEditProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _locationController;

  final UserController _userController = UserController();
  final CloudinaryService _cloudinaryService = CloudinaryService();

  String _profileImage = '';
  bool _isLoading = false;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _phoneController = TextEditingController(text: widget.user.phone);
    _addressController = TextEditingController(text: widget.user.address);
    _locationController = TextEditingController(text: widget.user.location);
    _profileImage = widget.user.profileImage;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    setState(() => _isUploadingImage = true);

    try {
      if (kIsWeb) {
        final pickedFile =
            await _cloudinaryService.pickImageFromGallery();
        if (pickedFile != null) {
          final bytes = await pickedFile.readAsBytes();
          final url =
              await _cloudinaryService.uploadImage(webBytes: bytes);
          setState(() => _profileImage = url);
        }
      } else {
        final url = await _userController.pickAndUploadImage();
        if (url != null) {
          setState(() => _profileImage = url);
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: SelectableText(error.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _userController.updateUserProfile(widget.user.userId, {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'location': _locationController.text.trim(),
        'profileImage': _profileImage,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: SelectableText(error.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Image Picker
              Center(
                child: GestureDetector(
                  onTap: _isUploadingImage ? null : _pickImage,
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFFF9800), width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF8F8F8),
                          backgroundImage: _profileImage.isNotEmpty ? NetworkImage(_profileImage) : null,
                          child: _isUploadingImage
                              ? const CircularProgressIndicator(color: Color(0xFFFF9800))
                              : _profileImage.isEmpty
                                  ? Icon(Icons.person_rounded, size: 50, color: Colors.grey.shade400)
                                  : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF9800),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              CustomTextField(
                controller: _nameController,
                label: 'Full Name',
                hintText: 'Enter your name',
                prefixIcon: Icons.person_rounded,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              CustomTextField(
                controller: _phoneController,
                label: 'Phone Number',
                hintText: 'Enter your phone number',
                prefixIcon: Icons.phone_rounded,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              CustomTextField(
                controller: _addressController,
                label: 'Address',
                hintText: 'Enter your address',
                prefixIcon: Icons.home_rounded,
              ),
              CustomTextField(
                controller: _locationController,
                label: 'City / Location',
                hintText: 'e.g. Lahore, Pakistan',
                prefixIcon: Icons.location_on_rounded,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? Colors.black : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: CustomButton(
            text: 'Save Changes',
            onPressed: _saveProfile,
            isLoading: _isLoading,
          ),
        ),
      ),
    );
  }
}
