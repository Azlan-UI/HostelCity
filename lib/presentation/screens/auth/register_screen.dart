import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/enums/user_role.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/province_city_selector.dart';
import '../../widgets/common/document_upload_widget.dart';
import '../../providers/auth_providers.dart';
import '../../../core/router/app_router.dart';


class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _imagePicker = ImagePicker();

  bool _isLoading = false;
  bool _obscurePassword = true;
  UserRole _selectedRole = UserRole.student;
  String? _selectedProvince;
  String? _selectedCity;
  
  // Student verification documents
  XFile? _studentCardFile;
  List<XFile> _certificateFiles = [];
  
  // Hostel admin verification documents
  XFile? _cnicFile;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickStudentCard() async {
    final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _studentCardFile = image;
      });
    }
  }

  Future<void> _pickCertificate() async {
    final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _certificateFiles.add(image);
      });
    }
  }

  Future<void> _pickCNIC() async {
    final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _cnicFile = image;
      });
    }
  }

  void _deleteCertificate(int index) {
    setState(() {
      _certificateFiles.removeAt(index);
    });
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedProvince == null || _selectedCity == null) {
      _showErrorSnackBar('Please select province and city');
      return;
    }

    if (_selectedRole == UserRole.student) {
      if (_studentCardFile == null) {
        _showErrorSnackBar('Please select your student card');
        return;
      }
      if (_certificateFiles.isEmpty) {
        _showErrorSnackBar('Please select at least one certificate');
        return;
      }
    }

    if (_selectedRole == UserRole.hostelAdmin) {
      if (_cnicFile == null) {
        _showErrorSnackBar('Please select your CNIC');
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      
      final user = await authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        role: _selectedRole,
        province: _selectedProvince!,
        city: _selectedCity!,
        phone: _phoneController.text.trim(),
        studentCardFile: _studentCardFile,
        certificateFiles: _certificateFiles,
        cnicFile: _cnicFile,
      );

      if (!mounted || user == null) return;
      Navigator.of(context).pushReplacementNamed(AppRouter.verificationPending);
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    String displayMessage = message;
    if (message.contains('Exception: [Error]')) {
      displayMessage = message.split('Exception: [Error]').last.trim();
    } else if (message.startsWith('Exception: ')) {
      displayMessage = message.substring(11);
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(displayMessage),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Create Account',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeInDown(
                  child: Text(
                    'Join Us',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                FadeInDown(
                  delay: const Duration(milliseconds: 100),
                  child: Text(
                    'Create your account to get started',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Role Selection
                FadeInUp(
                  delay: const Duration(milliseconds: 150),
                  child: Text(
                    'I am a',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: Wrap(
                    spacing: 12,
                    children: [
                      ChoiceChip(
                        label: Text(
                          'Student',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w500,
                            color: _selectedRole == UserRole.student 
                                ? AppColors.primary 
                                : AppColors.textPrimary,
                          ),
                        ),
                        selected: _selectedRole == UserRole.student,
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedRole = UserRole.student);
                        },
                      ),
                      ChoiceChip(
                        label: Text(
                          'Hostel Admin',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w500,
                            color: _selectedRole == UserRole.hostelAdmin 
                                ? AppColors.primary 
                                : AppColors.textPrimary,
                          ),
                        ),
                        selected: _selectedRole == UserRole.hostelAdmin,
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedRole = UserRole.hostelAdmin);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // Form Fields
                CustomTextField(
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  controller: _nameController,
                  validator: Validators.name,
                  prefixIcon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  label: 'Email',
                  hint: 'Enter your email',
                  controller: _emailController,
                  validator: Validators.email,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  label: 'Phone Number',
                  hint: 'Enter your phone number',
                  controller: _phoneController,
                  validator: Validators.requiredPhone,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_outlined,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  label: 'Password',
                  hint: 'Enter your password',
                  controller: _passwordController,
                  validator: Validators.strongPassword,
                  obscureText: _obscurePassword,
                  prefixIcon: Icons.lock_outline_rounded,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: AppColors.textTertiary,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
                const SizedBox(height: 32),
                
                // Location
                FadeInUp(
                  delay: const Duration(milliseconds: 250),
                  child: ProvinceCitySelector(
                    initialProvince: _selectedProvince,
                    initialCity: _selectedCity,
                    onSelectionChanged: (province, city) {
                      setState(() {
                        _selectedProvince = province;
                        _selectedCity = city;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 32),
                
                // Documents Header
                FadeInUp(
                  delay: const Duration(milliseconds: 300),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.verified_user_rounded, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text(
                              'Verification Documents',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Your account will be reviewed before approval',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Strategy based on role
                if (_selectedRole == UserRole.student) ...[
                  DocumentUploadWidget(
                    label: 'Student Card',
                    helpText: 'Upload a clear photo of your student ID card',
                    onFileSelected: (file) => setState(() => _studentCardFile = file),
                    onDelete: () => setState(() => _studentCardFile = null),
                    isLoading: false,
                    icon: Icons.badge_outlined,
                  ),
                  const SizedBox(height: 20),
                  MultiDocumentUploadWidget(
                    label: 'Certificates',
                    helpText: 'Upload eligibility certificates (e.g., admission letter)',
                    documents: _certificateFiles,
                    onAddDocument: _pickCertificate,
                    onDeleteDocument: _deleteCertificate,
                    isLoading: false,
                    maxDocuments: 5,
                  ),
                ],
                
                if (_selectedRole == UserRole.hostelAdmin) ...[
                  DocumentUploadWidget(
                    label: 'CNIC',
                    helpText: 'Upload a clear photo of your CNIC (front and back)',
                    onFileSelected: (file) => setState(() => _cnicFile = file),
                    onDelete: () => setState(() => _cnicFile = null),
                    isLoading: false,
                    icon: Icons.credit_card_outlined,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline_rounded, color: AppColors.info, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Hostel registration documents will be required when you add your hostel after verification',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                const SizedBox(height: 48),
                CustomButton(
                  text: 'Create Account',
                  onPressed: _handleRegister,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}