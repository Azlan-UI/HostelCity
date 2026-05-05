import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/user_model.dart';
import '../../providers/auth_providers.dart';
import '../../providers/service_providers.dart';
import 'custom_button.dart';
import 'custom_text_field.dart';

/// Shared edit-profile form; host screens enforce role.
class EditProfileBody extends ConsumerStatefulWidget {
  final UserModel user;

  const EditProfileBody({super.key, required this.user});

  @override
  ConsumerState<EditProfileBody> createState() => _EditProfileBodyState();
}

class _EditProfileBodyState extends ConsumerState<EditProfileBody> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  final _picker = ImagePicker();

  XFile? _pickedFile;
  Uint8List? _pickedPreview;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    _nameController = TextEditingController(text: u.name);
    _phoneController = TextEditingController(text: u.phone ?? '');
    _emailController = TextEditingController(text: u.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    setState(() {
      _pickedFile = file;
      _pickedPreview = bytes;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      String? imageUrl;
      if (_pickedFile != null) {
        imageUrl = await ref
            .read(storageServiceProvider)
            .uploadUserProfileImage(widget.user.userId, _pickedFile!);
      }
      final phoneTrim = _phoneController.text.trim();
      await ref.read(authServiceProvider).updateUserProfile(
            name: _nameController.text.trim(),
            phone: phoneTrim.isEmpty ? '' : phoneTrim,
            profileImageUrl: imageUrl,
          );
      ref.invalidate(currentUserProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')),
      );
      setState(() {
        _pickedFile = null;
        _pickedPreview = null;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final u = widget.user;
    final dateFmt = DateFormat.yMMMd();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _pickPhoto,
                      customBorder: const CircleBorder(),
                      child: CircleAvatar(
                        radius: 48,
                        backgroundColor: AppColors.surfaceAlt,
                        child: ClipOval(
                          child: _pickedPreview != null
                              ? Image.memory(
                                  _pickedPreview!,
                                  width: 96,
                                  height: 96,
                                  fit: BoxFit.cover,
                                )
                              : (u.profileImageUrl != null &&
                                      u.profileImageUrl!.isNotEmpty)
                                  ? CachedNetworkImage(
                                      imageUrl: u.profileImageUrl!,
                                      width: 96,
                                      height: 96,
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) => const Center(
                                        child: SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ),
                                      errorWidget: (_, __, ___) => _initials(u),
                                    )
                                  : _initials(u),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Material(
                      color: AppColors.accent,
                      shape: const CircleBorder(),
                      child: InkWell(
                        onTap: _pickPhoto,
                        customBorder: const CircleBorder(),
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(
                            Icons.camera_alt_rounded,
                            size: 18,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Tap to change photo',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 24),
            CustomTextField(
              label: 'Full name',
              hint: 'Your name',
              controller: _nameController,
              prefixIcon: Icons.person_outline_rounded,
              validator: Validators.name,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Phone',
              hint: 'Optional',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone_outlined,
              validator: Validators.phone,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Email',
              hint: u.email,
              controller: _emailController,
              enabled: false,
              prefixIcon: Icons.email_outlined,
            ),
            const SizedBox(height: 24),
            Text(
              'Account details',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _metaRow(Icons.place_outlined, 'Province', u.province),
            _metaRow(Icons.location_city_outlined, 'City', u.city),
            if (u.gender != null)
              _metaRow(Icons.wc_rounded, 'Gender', u.gender!.displayName),
            _metaRow(
              Icons.verified_outlined,
              'Verification',
              u.verificationStatus.displayName,
            ),
            _metaRow(
              Icons.calendar_today_outlined,
              'Member since',
              dateFmt.format(u.createdAt),
            ),
            if (u.hostelId != null && u.hostelId!.isNotEmpty)
              _metaRow(Icons.hotel_rounded, 'Hostel ID', u.hostelId!),
            const SizedBox(height: 28),
            CustomButton(
              text: 'Save changes',
              icon: Icons.save_rounded,
              isLoading: _saving,
              onPressed: _saving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }

  Widget _initials(UserModel u) {
    final letter = u.name.isNotEmpty ? u.name[0].toUpperCase() : 'U';
    return Center(
      child: Text(
        letter,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _metaRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.textTertiary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
