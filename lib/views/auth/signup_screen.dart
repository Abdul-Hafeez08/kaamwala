import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/auth_controller.dart';
import '../../services/cloudinary_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_loading_indicator.dart';
import 'login_screen.dart';
import '../worker/worker_profile_setup_screen.dart';
import '../user/user_main_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  final AuthController _authController = AuthController();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final ImagePicker _picker = ImagePicker();

  String _selectedRole = 'user';
  bool _isLoading = false;
  
  // Image handling
  String _profileImageUrl = '';
  File? _mobileImageFile;
  Uint8List? _webImageBytes;
  bool _isUploadingImage = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (picked != null) {
        setState(() => _isUploadingImage = true);
        
        if (kIsWeb) {
          final bytes = await picked.readAsBytes();
          setState(() {
            _webImageBytes = bytes;
            _mobileImageFile = null;
          });
          final url = await _cloudinaryService.uploadImage(webBytes: bytes);
          setState(() => _profileImageUrl = url);
        } else {
          final file = File(picked.path);
          setState(() {
            _mobileImageFile = file;
            _webImageBytes = null;
          });
          final url = await _cloudinaryService.uploadImage(imageFile: file);
          setState(() => _profileImageUrl = url);
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: SelectableText('Upload Error: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authController.signUp(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        password: passwordController.text.trim(),
        role: _selectedRole,
        profileImage: _profileImageUrl, // Pass the uploaded image URL
      );

      if (!mounted) return;

      if (_selectedRole == 'worker') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const WorkerProfileSetupScreen()),
        );
      } else {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const UserMainScreen()),
        );
      }
    } catch (error) {
      if (mounted) _showMessage(error.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Theme.of(context).primaryColor,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Join the Kaamwala community',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 32),

                  // Profile Image Picker
                  Center(
                    child: Column(
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
                            backgroundImage: _isUploadingImage 
                              ? null 
                              : (_webImageBytes != null 
                                  ? MemoryImage(_webImageBytes!) as ImageProvider
                                  : (_mobileImageFile != null 
                                      ? FileImage(_mobileImageFile!)
                                      : (_profileImageUrl.isNotEmpty ? NetworkImage(_profileImageUrl) : null))),
                            child: _isUploadingImage
                                ? const CustomLoadingIndicator(size: 30)
                                : (_profileImageUrl.isEmpty && _mobileImageFile == null && _webImageBytes == null
                                    ? Icon(Icons.add_a_photo_rounded, size: 30, color: Colors.grey.shade400)
                                    : null),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton.icon(
                              onPressed: () => _pickImage(ImageSource.gallery),
                              icon: const Icon(Icons.photo_library_rounded, size: 18),
                              label: const Text('Gallery', style: TextStyle(fontSize: 12)),
                              style: TextButton.styleFrom(foregroundColor: const Color(0xFFFF9800)),
                            ),
                            TextButton.icon(
                              onPressed: () => _pickImage(ImageSource.camera),
                              icon: const Icon(Icons.camera_alt_rounded, size: 18),
                              label: const Text('Camera', style: TextStyle(fontSize: 12)),
                              style: TextButton.styleFrom(foregroundColor: const Color(0xFFFF9800)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  CustomTextField(
                    controller: nameController,
                    label: 'Full Name',
                    hintText: 'Enter your name',
                    prefixIcon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter your name';
                      return null;
                    },
                  ),

                  CustomTextField(
                    controller: emailController,
                    label: 'Email',
                    hintText: 'Enter your email',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter your email';
                      if (!value.contains('@')) return 'Please enter a valid email';
                      return null;
                    },
                  ),

                  CustomTextField(
                    controller: phoneController,
                    label: 'Phone Number',
                    hintText: '03XXXXXXXXX',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter your phone number';
                      if (value.length != 11) return 'Phone number must be 11 digits';
                      return null;
                    },
                  ),

                  CustomTextField(
                    controller: passwordController,
                    label: 'Password',
                    hintText: 'At least 6 characters',
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter a password';
                      if (value.length < 6) return 'Password must be at least 6 characters';
                      return null;
                    },
                  ),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: DropdownButtonFormField<String>(
                      value: _selectedRole,
                      decoration: InputDecoration(
                        labelText: 'I am a',
                        prefixIcon: const Icon(Icons.badge_outlined),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      items: const [
                        DropdownMenuItem(value: 'user', child: Text('User (Customer)')),
                        DropdownMenuItem(value: 'worker', child: Text('Worker (Service Provider)')),
                      ],
                      onChanged: (value) {
                        if (value != null) setState(() => _selectedRole = value);
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  CustomButton(
                    text: 'Create Account',
                    onPressed: _handleSignup,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Already have an account? ', style: TextStyle(color: Colors.grey.shade600)),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          );
                        },
                        child: Text(
                          'Login',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
